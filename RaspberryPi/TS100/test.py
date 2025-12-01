import bleak

# 설치된 버전 확인
print(f"Bleak 버전: {bleak.__version__}")
print("Bleak 모듈 구조:")
for name in dir(bleak):
    if not name.startswith("__"):
        print(f"- {name}")