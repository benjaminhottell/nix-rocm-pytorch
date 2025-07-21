#!/usr/bin/env python3

# Test to ensure pytorch is (probably) working


import torch

print('Cuda is avilable:', torch.cuda.is_available())

print('Cuda devices:', torch.cuda.device_count())

current_device = torch.cuda.current_device()

print('Current device:', current_device)
print('Current device name:', torch.cuda.get_device_name(current_device))


print()


# Official test from:
# https://pytorch.org/get-started/locally/

x = torch.rand(5, 3)
print(x)

