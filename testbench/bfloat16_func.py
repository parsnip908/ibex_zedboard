import numpy as np
import bfloat16
import tensorflow as tf

tensor1 = tf.random.uniform(shape=[20], dtype = tf.bfloat16)
print(tensor1)
tensor2 = tf.random.uniform(shape=[20], dtype = tf.bfloat16)
print(tensor2)
tensor_total = tensor1 + tensor2
print(tensor_total)
tensor_total2 = tensor1 - tensor2
print(tensor_total2)
tensor_total3 = tensor1 * tensor2
print(tensor_total3)
