
import torch
from setuptools import find_packages, setup
from torch.utils.cpp_extension import CppExtension


requirements = ["torch", "torchvision"]

setup(
    name="ltisi_benchmark",
    version="0.1",
    author="Shichao Kan",
    url="https://github.com/kanshichao/LTI-ST",
    description="LTI-ST",
    packages=find_packages(exclude=("configs", "tests")),
    install_requires=requirements,
    cmdclass={"build_ext": torch.utils.cpp_extension.BuildExtension},
)
