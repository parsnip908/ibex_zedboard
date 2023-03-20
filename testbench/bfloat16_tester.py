import struct

def bf16_to_decimal(num):

    sign = int(num[0],2)
    exponent = int(num[1:9],2) - 127
    mantissa = (num[9:16])
    sum = 1
    count = 0

    for i in range(len(mantissa)):
        
        if(int(mantissa[i]) == 1):
            count += 1

        sum += int(mantissa[i]) * pow(2, -(i+1))
    
    number = pow(-1, sign) * pow(2,exponent) * sum

    if(mantissa == '0000000'):
        if(exponent == 128):
            match sign:
                case 0: number = "+inf"
                case 1: number = "-inf"
        elif(exponent == -127):
            match sign:
                case 0: number = "+0"
                case 1: number = "-0"
    elif(count > 0 and exponent == 128):
        match sign:
            case 0: number = "+NaN"
            case 1: number = "-NaN"

    return number

def float2bin32(f):
    [d] = struct.unpack(">I", struct.pack(">f", f))
    return f'{d:032b}'

def bf16_add(num1, num2):
    
    if(num1 == '+NaN' or num1 == '-NaN' or num2 == '+NaN' or num2 == '-NaN'):
        return 'NaN'
    elif(num1 == '+inf' or num1 == '-inf' or num2 == '+inf' or num2 == '-inf'):
        return 'inf'
    elif((num1 == '+0' or num1 == '-0') and (num2 == '+0' or num2 == '-0')): #both 0
        return 0.0
    elif(num1 == '+0' or num1 == '-0'): #num 1 = 0
        return num2
    elif(num2 == '+0' or num2 == '-0'): #num2 = 0
        return num1
    else:
        return num1 + num2

def bf16_multiply(num1, num2):
    
    if(num1 == '+NaN' or num1 == '-NaN' or num2 == '+NaN' or num2 == '-NaN'):
        return 'NaN'
    elif(num1 == '+inf' or num1 == '-inf' or num2 == '+inf' or num2 == '-inf'):
        return 'inf'
    elif(num1 == '+0' or num1 == '-0' or num2 == '+0' or num2 == '-0'): #both 0
        return 0.0
    else:
        return num1 * num2

file1 = open("Array1.txt", 'r') #specify first file with random numbers
file2 = open("Array2.txt", 'r') #specify second file with random numbers
array1 = []
array2 = []
array_sum = []
array_product = []

#read both files and add to separate arrays as decimal floats

for lines in file1:
    array1.append(bf16_to_decimal(lines))

for lines in file2:
    array2.append(bf16_to_decimal(lines))

file1.close()
file2.close()

array_result_sum = []
array_result_product = []

#add the contents

for i in range(len(array1)):
    array_sum.append(bf16_add(array1[i],array2[i])) 

#multiply the contents

for i in range(len(array1)):
    array_product.append(bf16_multiply(array1[i],array2[i])) 

#convert back to bfloat16

for lines in array_sum:
    if(type(lines)== float):
         x = float2bin32(lines)
         array_result_sum.append(x[0:16])
    else:
        array_result_sum.append(lines)

for lines in array_product:
    if(type(lines)== float):
         x = float2bin32(lines)
         array_result_product.append(x[0:16])
    else:
        array_result_product.append(lines)

#Write to file

file_result_sum = open("Sum_python.txt", "w")
file_result_multiply = open("Product_python.txt", "w")

for lines in array_result_sum:
    file_result_sum.write(lines+"\n")

for lines in array_result_product:
    file_result_multiply.write(lines+"\n")

file_result_sum.close()
file_result_multiply.close()


#read verilog sum output

file_verilog_sum = open("Sum_verilog.txt", "r")

array_verilog_sum = []

for lines in file_verilog_sum:
    array_verilog_sum.append(lines)

file_verilog_sum.close()

#write comparison results to another file

file_compare_sum = open("Compare_Sum.txt", "w")

for i in range(len(array_result_sum)):
    if(array_result_sum[i].strip() == array_verilog_sum[i].strip()):
        # print("line " + str(i+1) + " match")
        file_compare_sum.write(("line " + str(i+1) + " match\n"))
    else:
        # print("line " + str(i+1) + " mismatch")
        file_compare_sum.write(("line " + str(i+1) + " mismatch\n"))

file_compare_sum.close()



# for i in range(len(array_verilog_sum)):
#     print(array_result_sum[i])
#     print(array_verilog_sum[i])
#     # print("\n")


#intermediary files, for checking only

file_sum= open("Results_decimal_sum.txt", "w")
# file_multiply= open("Results_decimal_multiply.txt", "w")


for lines in array_sum:
    file_sum.write(str(lines)+"\n")

# for lines in array_multiply:
#     file_multiply.write(str(lines)+"\n")

file_sum.close()
# file_multiply.close()



########################################

#read verilog product output

# file_verilog_product = open("Mul.txt", "r")

# array_verilog_product = []

# for lines in file_verilog_product:
#     array_verilog_product.append(lines)

# file_verilog_product.close()

# for i in range(len(array_verilog_product)):
#     if(array_result_multiply[i].strip() == array_verilog_product[i].strip()):
#         print("line " + str(i+1) + " match")
#     else:
#         print("line " + str(i+1) + " mismatch")
