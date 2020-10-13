import os 
import sys
job_name=sys.argv[1]
initial_path=os.path.join(r"remote_workdirectory" ,job_name)
files=os.listdir(r"{0}".format(initial_path))
need=[ file for  file  in files if (os.path.splitext(file)[1].lower() in [".png",".jpg",".jpeg"])]
actual_path=os.path.join(initial_path,need[0])
li=f'source="{actual_path}" '
li=li.replace("\\","/")
image_ext=os.path.splitext(need[0])[1]
print(li)
from fileinput import FileInput
     with FileInput(r"path/to_s3.tf",inplace=True) as fp:
          for line in fp:
               if  'source="c' in line.lower():
                    print(line.replace(line.strip(),li.strip()))
               else:
                    print(line.strip())         


    



