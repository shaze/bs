#!/usr/bin/env python3
import sys

project=sys.argv[1]
cli_download = open(sys.argv[2])
report = open(sys.argv[3])

bc2dataset_id={}
for line in cli_download:
   [barcode,dataset_id,proj,other]=line.split(',')
   bc2dataset_id[barcode]=dataset_id

for line in report:
   if "Patient" in line: break

err=open("%s_unknown_samples"%project,"w")
   
for line in report:
   data=line.split(',')
   our_sample_id=data[0]
   biosample=data[1]
   if biosample in bc2dataset_id:
      print("%s\t%s"%(our_sample_id,bc2dataset_id[biosample]))
   else:
      err.write("%s %s\n"%(our_sample_id,biosample))

err.close()
report.close()
cli_download.close()
