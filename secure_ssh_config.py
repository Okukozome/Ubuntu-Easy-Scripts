import re
import os

if os.geteuid() != 0:
    print("需以sudo运行")
    exit(1)

CONFIGS = {
    "PasswordAuthentication": "no",
    "ChallengeResponseAuthentication": "no",
    "KbdInteractiveAuthentication": "no",
    "GSSAPIAuthentication": "no",
    "PubkeyAuthentication": "yes",
    "AuthenticationMethods": "publickey"
}

with open("/etc/ssh/sshd_config", 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    # 注释Include行
    if line.strip().startswith("Include") and not line.strip().startswith("#"):
        new_lines.append(f"# {line}")
    else:
        new_lines.append(line)

# 更新配置
for key, value in CONFIGS.items():
    pattern = rf"^{key}\s+.*$"
    found = False
    for i, line in enumerate(new_lines):
        if re.match(pattern, line.strip(), re.IGNORECASE):
            if not line.strip().startswith("#"):
                new_lines[i] = f"{key} {value}\n"
            found = True
            break
    if not found:
        new_lines.append(f"{key} {value}\n")

# 写回文件
with open("/etc/ssh/sshd_config", 'w') as f:
    f.writelines(new_lines)
print("请手动重启SSH服务以使配置生效：")
print("systemctl restart sshd")
