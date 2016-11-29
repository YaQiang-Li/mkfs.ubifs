# mkfs.ubifs制作流程：
1.在mtd文件夹底下运行mtd.sh,注意修改其中交叉编译链为自己开发板的交叉编译链,目前底下已下载了3个好的安装包，如需升级修改mtd.sh中的下载包名字即可
2.完成第一步后下载busybox制作文件系统，busy编译为静态编译，编译好后将make CONFIG_PREFIX=../ubifs install
3.完成这一步骤后执行./mkimg.sh即可得到ubifs.img镜像，注意修改ubinize.cfg为目标文件系统大小和块大小
