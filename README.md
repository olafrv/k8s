# k8s

# https://www.packer.io/downloads.html
# https://raw.githubusercontent.com/pavel-klimiankou/packer-example/master/http/preseed.cfg
# https://codeblog.dotsandbrackets.com/build-image-packer/

Script can be run on each host with:
```
ssh <host> 'bash -s' < script.sh
```

mkdir -p $(go env GOPATH)/src/github.com/hashicorp && cd $_
git clone https://github.com/hashicorp/packer.git
cd packer