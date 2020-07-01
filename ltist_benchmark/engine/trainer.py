
import datetime
import time

import numpy as np
import torch

from ltist_benchmark.data.evaluations import RetMetric
from ltist_benchmark.utils.feat_extractor import feat_extractor
from ltist_benchmark.utils.freeze_bn import set_bn_eval
from ltist_benchmark.utils.metric_logger import MetricLogger

def update_ema_variables(model,ema_model):
    alpha = 0.999
    for ema_param, param in zip(ema_model.parameters(), model.parameters()):
        ema_param.data.mul_(alpha).add_(1-alpha,param.data)

def do_train(
        cfg,
        model,
        train_loader,
        val_loader,
        optimizer,
        scheduler,
        criterion,
        criterion_aux,
        checkpointer,
        device,
        checkpoint_period,
        arguments,
        logger
):
    logger.info("Start training")
    meters = MetricLogger(delimiter="  ")
    max_iter = len(train_loader)

    start_iter = arguments["iteration"]
    best_iteration = -1
    best_recall = 0

    start_training_time = time.time()
    end = time.time()
    for iteration, (images, targets) in enumerate(train_loader, start_iter):

        if iteration % cfg.VALIDATION.VERBOSE == 0 or iteration == max_iter:
            model.eval()
            logger.info('Validation')
            labels = val_loader.dataset.label_list
            labels = np.array([int(k) for k in labels])
            feats = feat_extractor(model, val_loader, logger=logger)

            ret_metric = RetMetric(feats=feats, labels=labels)
            recall_curr = []
            recall_curr.append(ret_metric.recall_k(1))
            recall_curr.append(ret_metric.recall_k(2))
            recall_curr.append(ret_metric.recall_k(4))
            recall_curr.append(ret_metric.recall_k(8))

            print(recall_curr)

            if recall_curr[0] > best_recall:
                best_recall = recall_curr[0]
                best_iteration = iteration
                logger.info(f'Best iteration {iteration}: recall@1: {recall_curr[0]:.3f}')
                checkpointer.save(f"best_model")
            else:
                logger.info(f'Recall@1 at iteration {iteration:06d}: recall@1: {recall_curr[0]:.3f}')

        model.train()
        model.apply(set_bn_eval)

        data_time = time.time() - end
        iteration = iteration + 1
        arguments["iteration"] = iteration

        scheduler.step()

        images = images.to(device)
        targets = torch.stack([target.to(device) for target in targets])

        feats = model(images)
        if criterion_aux is not None:
            if cfg.LOSSES.NAME_AUX is not 'adv_loss':
                loss = criterion(feats, targets)
                loss_aux = criterion_aux(feats, targets)
                loss = (1-cfg.LOSSES.AUX_WEIGHT)*loss + cfg.LOSSES.AUX_WEIGHT*loss_aux
            else:
                loss = criterion(feats, targets)
                feats=torch.split(feats,cfg.LOSSES.ADV_LOSS.CLASS_DIM,dim=1)
                loss_aux = criterion_aux(feats[0], feats[1])
                loss = (1-cfg.LOSSES.AUX_WEIGHT)*loss + cfg.LOSSES.AUX_WEIGHT * loss_aux
        else:
            loss = criterion(feats, targets)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        batch_time = time.time() - end
        end = time.time()
        meters.update(time=batch_time, data=data_time, loss=loss.item())

        eta_seconds = meters.time.global_avg * (max_iter - iteration)
        eta_string = str(datetime.timedelta(seconds=int(eta_seconds)))

        if iteration % 20 == 0 or iteration == max_iter:
            logger.info(
                meters.delimiter.join(
                    [
                        "eta: {eta}",
                        "iter: {iter}",
                        "{meters}",
                        "lr: {lr:.6f}",
                        "max mem: {memory:.1f} GB",
                    ]
                ).format(
                    eta=eta_string,
                    iter=iteration,
                    meters=str(meters),
                    lr=optimizer.param_groups[0]["lr"],
                    memory=torch.cuda.max_memory_allocated() / 1024.0 / 1024.0 / 1024.0,
                )
            )

        if iteration % checkpoint_period == 0:
            checkpointer.save("model_{:06d}".format(iteration))

    total_training_time = time.time() - start_training_time
    total_time_str = str(datetime.timedelta(seconds=total_training_time))
    logger.info(
        "Total training time: {} ({:.4f} s / it)".format(
            total_time_str, total_training_time / (max_iter)
        )
    )

    logger.info(f"Best iteration: {best_iteration :06d} | best recall {best_recall} ")

def do_test(
        model,
        val_loader,
        logger
):
    logger.info("Start testing")
    model.eval()
    logger.info('test')

    labels = val_loader.dataset.label_list
    labels = np.array([int(k) for k in labels])
    feats = feat_extractor(model, val_loader, logger=logger)

    ret_metric = RetMetric(feats=feats, labels=labels)
    recall_curr = []
    recall_curr.append(ret_metric.recall_k(1))
    recall_curr.append(ret_metric.recall_k(2))
    recall_curr.append(ret_metric.recall_k(4))
    recall_curr.append(ret_metric.recall_k(8))

    print(recall_curr)
