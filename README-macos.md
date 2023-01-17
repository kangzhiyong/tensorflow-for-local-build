## 安装环境

*   OS Platform and Distribution

&#x9;	macos Ventura 13.1

*   Architecture

&#x9;	Intel x86\_64

*   Tensorflow Version

&#x9;	tf 2.11.0

*   Python version

&#x9;	3.9.13

*   Bazel version

&#x9;	5.3.0

*   Xcode version

&#x9;	14.2

## [从源代码构建](https://tensorflow.google.cn/install/source)

### macOS设置

*   miniconda创建虚拟环境及tensorflow依赖项安装

```bash
conda create -n tf python==3.9.13
conda activate tf
pip install -U pip numpy wheel
pip install -U keras_preprocessing --no-deps
```

*   安装Bazel

```bash
brew install bazel
```

*   下载 TensorFlow 源代码

```bash
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout r2.11
```

### 配置 build

```bash
# Check whether script is executing in a VirtualEnv or Conda environment
if [ -z "$VIRTUAL_ENV" ] && [ -z "$CONDA_PREFIX" ] ; then
	echo "VirtualEnv or Conda env is not activated"
	exit -1
fi

# Set the virtual environment path
if ! [ -z "$VIRTUAL_ENV" ] ; then
  VENV_PATH=$VIRTUAL_ENV
elif ! [ -z "$CONDA_PREFIX" ] ; then
  VENV_PATH=$CONDA_PREFIX
fi

# Set the bin and lib directories
VENV_BIN=$VENV_PATH/bin
VENV_LIB=$VENV_PATH/lib

# bazel tf needs these env vars
export PYTHON_BIN_PATH=$VENV_BIN/python
export PYTHON_LIB_PATH=`ls -d $VENV_LIB/*/ | grep python`

# Set the native architecture optimization flag, which is a default
COPT="--copt=-march=native"

# Determine the available features of your CPU
raw_cpu_flags=`sysctl -a | grep machdep.cpu.features | cut -d ":" -f 2 | tr '[:upper:]' '[:lower:]'`

# Append each of your CPU's features to the list of optimization flags
for cpu_feature in $raw_cpu_flags
do
	case "$cpu_feature" in
		"sse4.1" | "sse4.2" | "ssse3" | "fma" | "cx16" | "popcnt" | "maes")
		    COPT+=" --copt=-m$cpu_feature"
		;;
		"avx1.0")
		    COPT+=" --copt=-mavx"
		;;
		*)
			# noop
		;;
	esac
done

echo $COPT

# First ensure a clear working directory in case you've run bazel previously
bazel clean --expunge

# Run TensorFlow configuration (accept defaults unless you have a need)
python configure.py

# Build the TensorFlow pip package
bazel build -c opt $COPT -k //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
```

### 安装测试软件包

```bash
cd ../
pip uninstall tensorflow  # remove current version

pip install /tmp/tensorflow_pkg/tensorflow-version-tags.whl
python -c "import tensorflow as tf; print(tf.__version__)"
```

## 编译异常处理

### 1、第三方源码包无法下载

*   &#x9;问题现象：

```javascript
	Download from https://storage.googleapis.com/mirror.tensorflow.org/github.com/google/XNNPACK/archive/a50369c0fdd15f0f35b1a91c964644327a88d480.zip failed: class java.io.IOException connect timed out
```

*   &#x9;解决方法：

    1.  从该链接直接下载文件包，[https://github.com/google/XNNPACK/archive/a50369c0fdd15f0f35b1a91c964644327a88d480.zip](https://storage.googleapis.com/mirror.tensorflow.org/github.com/google/XNNPACK/archive/a50369c0fdd15f0f35b1a91c964644327a88d480.zip)，（国内下载不了，方法不再赘述）。
    2.  本地搭建http服务器，用于存放无法下载的程序包，提供本地下载地址
    3.  修改bzl文件，增加本地链接，例如以上链接是在tensorflow\tensorflow\workspace2.bzl中

&#x9;		原文内容：

    tf_http_archive(
        name = "XNNPACK",
        sha256 = "7a16ab0d767d9f8819973dbea1dc45e4e08236f89ab702d96f389fdc78c5855c",
        strip_prefix = "XNNPACK-e8f74a9763aa36559980a0c2f37f587794995622",
        urls = tf_mirror_urls("https://github.com/google/XNNPACK/archive/e8f74a9763aa36559980a0c2f37f587794995622.zip"),
    )

&#x9;		替换为：

    tf_http_archive(
        name = "XNNPACK",
        sha256 = "ca3a5316b8161214f8f22a578fb638f1fccd0585eee40301363ffd026310379a",
        strip_prefix = "XNNPACK-a50369c0fdd15f0f35b1a91c964644327a88d480",
        urls = ["https://storage.googleapis.com/mirror.tensorflow.org/github.com/google/XNNPACK/archive/a50369c0fdd15f0f35b1a91c964644327a88d480.zip",
                "http://127.0.0.1:8080/tensorflow/XNNPACK-a50369c0fdd15f0f35b1a91c964644327a88d480.zip"
        ],
    )

### 2、Go无法下载安装

*   &#x9;	问题现象：

        			Download from https://golang.org/dl/?mode=json&include=all failed: class java.io.IOException connect timed out

*   &#x9;	 解决方法：

1.  该错误io\_bazel\_rules\_go需要下载go软件包引起的，需要修改io\_bazel\_rules\_go这个包中的sdk.bzl文件。从tensorflow\tensorflow\workspace2.bzl中找到这个包的[下载地址](https://github.com/bazelbuild/rules_go/releases/download/v0.34.0/rules_go-v0.34.0.zip)，下载到本地，放到本地http服务器
2.  修改tensorflow\tensorflow\workspace2.bzl文件，注意sha256也需要修改，可以通过tensorflow编译错误获取，同时需要删除/var/tmp/*bazel\[loginName]/cache/repos/v1/content*\_addressable/sha256下面和sha256同名文件，避免无法使用修改后的文件：

&#x9;	原文内容：

    	tf_http_archive(
        name = "io_bazel_rules_go",
        sha256 = "80cbfe287bacbe6cec97f0446a413fee7c21dafda3981b9de71a35eebbc89e1f",
        urls = tf_mirror_urls("https://github.com/bazelbuild/rules_go/releases/download/v0.34.0/rules_go-v0.34.0.zip"),
        ],
    )



    	tf_http_archive(
        name = "io_bazel_rules_go",
        sha256 = "80cbfe287bacbe6cec97f0446a413fee7c21dafda3981b9de71a35eebbc89e1f",
        #urls = tf_mirror_urls("https://github.com/bazelbuild/rules_go/releases/download/v0.34.0/rules_go-v0.34.0.zip"),
        urls = ["http://127.0.0.1:8080/tensorflow/rules_go-v0.34.0.zip"
        ],
    )

&#x9;2、[下载go.json](https://golang.org/dl/?mode=json\&include=all)文件，放到本地http服务器，sha256值需要计算传入，可以通过替换bzl中某个包，让tensorflow编译时报错，提示出该文件的sha256值

&#x9;3、解压下载的zip包，打开	rules\*\_go-v0.34.0\go\private\sdk.bzl，修改以下内容\*

&#x9;		原文内容：

    ctx.download(
                url = [
                    "https://golang.org/dl/?mode=json&include=all",
                    "https://golang.google.cn/dl/?mode=json&include=all",
                ],
                output = "versions.json",
            )

    ......

    _go_download_sdk = repository_rule(
        implementation = _go_download_sdk_impl,
        attrs = {
            "goos": attr.string(),
            "goarch": attr.string(),
            "sdks": attr.string_list_dict(),
            "urls": attr.string_list(default = ["https://dl.google.com/go/{}"]),
            "version": attr.string(),
            "strip_prefix": attr.string(default = "go"),
        },
    )

&#x9;		替换为

    ctx.download(
    url = [
    #"https://golang.org/dl/?mode=json&include=all",
    #"https://golang.google.cn/dl/?mode=json&include=all",
    "http://127.0.0.1:8080/tensorflow/go.json",
    ],
    output = "versions.json",
    sha256 = "47bd74d7eac125a61194d1aa2688c2da3e3bc1bb0981d41a7dd0e9f9cc88d57c",
    )

    ......

    _go_download_sdk = repository_rule(
        implementation = _go_download_sdk_impl,
        attrs = {
            "goos": attr.string(),
            "goarch": attr.string(),
            "sdks": attr.string_list_dict(),
            "urls": attr.string_list(default = ["http://127.0.0.1:8080/tensorflow/{}"]),
            "version": attr.string(),
            "strip_prefix": attr.string(default = "go"),
        },
    )

&#x9;4、重新zip压缩rules\_go-v0.34.0.zip，需要根据编译错误提示更改sha256

### 3、ld: malformed trie, node past end file 'bazel-out/host/bin/\_solib\_darwin\_x86\_64/libtensorflow\_Spython\_S\_Upywrap\_Utensorflow\_Uinternal.so'

&#x9;1、该问题是由于xcode14升级引起的，将ld切换成13版本可以暂时解决该问题，[查看该链接](https://medium.com/p/9b90d55e92df)

&#x9;2、从苹果官网下载xcode13，解压后，将ld拷贝到本机目录下，本机的备份

### 4、安装打包好的wheel时，提示：error\:tensorflow-\*.whl is not suported wheel on this platform

&#x9;1、tensorflow, 版本不对，目前编译打包成功的时v2.11.0版本

&#x9;2、python版本不对，必须用编译打包时使用的python pip安装

&#x9;3、在虚环境安装中安装会报这个错误，退出虚环境在base中安装

### 5、dlopen(/Users/davidlaxer/tensorflow-metal/lib/python3.8/site-packages/tensorflow-plugins/libmetal\_plugin.dylib, 6): Symbol not found:

&#x9;1、本地原因是之前安装了tensorflow-macos，需要卸载之前安装的所有tensorflow依赖包
