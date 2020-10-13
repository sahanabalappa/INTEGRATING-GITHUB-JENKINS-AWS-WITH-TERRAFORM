import sys
import os
from fileinput import FileInput
def get_var_value(filename="value_counts.txt"):
    with open(filename, "r+") as f:
        f.seek(0)
        val = int(f.read()) + 1
        f.seek(0)
        f.write(str(val))
        return val
    
url=sys.argv[1]    # this argument i am passing through the s3.tf file
content_type=os.path.basename(url)
content_type=os.path.splitext(content_type)[1]
count=get_var_value()

if count==1:
    web_initial_path="remote_workspace_for_jenkins_slave/job1"
    web_files=os.listdir(web_initial_path)

else:
    web_initial_path="remote_workspace_for_jenkins_slave/job2"
    web_files=os.listdir(web_initial_path)
web_need=[ file for  file  in web_files if (os.path.splitext(file)[1].lower() in [".html",".js",".php"])]
web_actual_path=os.path.join(web_initial_path,web_need[0])
web_li=f'source="{web_actual_path}" '

web_li=web_li.replace("\\","/")
print(web_li)

with FileInput(web_actual_path,inplace=True) as ip:
    for line in ip:
        if "<img src" in line or content_type in line :
            str=f'<img src ="{url}" class="img-fluid" alt="Responsive image">  '   # changing the image_url
            print(line.replace(line,str))
        else:
             print(line.strip())

web=web_need[0]
web=os.path.splitext(web)[1]
target_actual_path=os.path.join("\\var\www\html",web_need[0])
print(target_actual_path)
web_li_target=f'destination="{target_actual_path}" '
web_li_target=web_li_target.replace("\\","/")
print(web_li_target)

st=f'''resource "null_resource" "site"[       # creating the index.tf file

connection [
    type     = "ssh"
    user     = "ec2-user"
    private_key=tls_private_key.my_key.private_key_pem
    host     = aws_instance.my_instance.public_ip
  ]

provisioner "file"[

{web_li}
{web_li_target}
]
]
'''

st=st.replace("[","{")
st=st.replace("]","}")


file=os.path.splitext(web_need[0])[0]+".tf"
with open(file,"w") as fp:
    fp.write(st)



#os.system("terraform taint null_resource.site")
#os.system("terraform apply -auto-approve")

   


