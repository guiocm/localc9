#!/bin/sh

CLOUD9_URL=https://github.com/ajaxorg/cloud9/archive/5b62a7c83445ccba9f50592d41a7128b1f1fe868.zip

NODEJS_BASE_URL=http://nodejs.org/dist
NODEJS_VERSION=v0.8.26

# CLOUD9_URL=http://localhost:8000/5b62a7c83445ccba9f50592d41a7128b1f1fe868.zip
# NODEJS_X64_URL=http://localhost:8000/node-v0.8.26-linux-x64.tar.gz
# NODEJS_X86_URL=http://localhost:8000/node-v0.8.26-linux-x86.tar.gz

ROOT_DIR=`pwd`
# If you change these subdirectory, change bin/cloud9 accordingly
NODEJS_DIR=$ROOT_DIR/nodejs
CLOUD9_DIR=$ROOT_DIR/cloud9

# Setup NodeJS
if [ ! -d $NODEJS_DIR ]; then
    mkdir -p $NODEJS_DIR
    
    case `uname -a` in
    Linux*x86_64*)
        arch=x64
        ;;

    Linux*i686*)
        arch=x86
        ;;
        
    *)
        echo "Could not find a suitable NodeJS version (unsupported OS)"
        exit
        ;;
    esac

    echo "Downloading NodeJS for Linux ${arch}"

    nodejs_file=node-${NODEJS_VERSION}-linux-${arch}.tar.gz
    wget ${NODEJS_BASE_URL}/${NODEJS_VERSION}/${nodejs_file}
    if [ $? != 0 ]; then
        echo "Error downloading NodeJS."
        exit
    fi;        

    tar xzvf $nodejs_file -C $NODEJS_DIR
    
    # Move to the right directory
    subdir=`find $NODEJS_DIR -maxdepth 1 -and -not -path $NODEJS_DIR`
    mv $subdir/* $NODEJS_DIR
    rm -r $subdir

    rm $nodejs_file
fi
export PATH=$PATH:$NODEJS_DIR/bin

# Setup Cloud9
if [ ! -d $CLOUD9_DIR ]; then
    mkdir -p $CLOUD9_DIR
    
    echo "Downloading Cloud9"
    wget $CLOUD9_URL -O cloud9.zip
    if [ $? != 0 ]; then
        echo "Error downloading Cloud9."
        exit
    fi;    
    
    unzip cloud9.zip -d $CLOUD9_DIR
    
    # Move to the right directory
    subdir=`find $CLOUD9_DIR -maxdepth 1 -and -not -path $CLOUD9_DIR`
    mv $subdir/* $CLOUD9_DIR
    rm -r $subdir

    rm cloud9.zip

    cd $CLOUD9_DIR
    npm install
    
    # Patch cloud9 with some improvements and adaptations
    if [ "$1" != "nopatch" ]; then
        echo "Applying patches..."
        cd $ROOT_DIR
        patch -d $CLOUD9_DIR -p1 < cloud9.patch
        
        cd $CLOUD9_DIR
        npm install
    fi
else
    echo "Files are in place, updating..."
    cd $CLOUD9_DIR
    npm update
fi
cd $ROOT_DIR

# Update bashrc to add the path for cloud9
CLOUD9_PATH="export PATH=\$PATH:$ROOT_DIR/bin"
grep -v "$CLOUD9_PATH" ~/.bashrc > ~/.bashrc.new
echo "$CLOUD9_PATH" >> ~/.bashrc.new
mv ~/.bashrc ~/.bashrc.old
mv ~/.bashrc.new ~/.bashrc

chmod +x $ROOT_DIR/bin/cloud9

echo "Installation is complete."
echo "Start a new shell session and run the cloud9 command."
exit
