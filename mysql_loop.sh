#!/bin/sh
# Date: 2017/09/17
#
# 1. 脚本可重入执行
# 2. 卸载 loop 设备和文件将会保存数据
#
# 流程:
#   1. 创建 loop 文件 [dd]
#   2. 绑定 loop 文件和 loop 设备 [losetup]
#   3. 格式化 loop 设备 [mkfs.ext4]
#   4. 挂载 loop 设备 [mount]
#
################################################################################
# 全局变量
ROOT=$(dirname $0)
loop_file="$(realpath ${ROOT}/mysql.loop)"
loop_file_size=1024
loop_file_mount_point="$(realpath ${ROOT}/mysql_mp)"

################################################################################
# 工具函数
log() {
    echo [`date +"%F %T"`] INFO: $*
}

help() {
    log "$0 <install|uninstall>"
}

check_uid(){
    effective_user_id=$(id -u)
    if [ $effective_user_id -ne 0 ]; then
        log "only root can execute this script"
        exit 1
    fi
}
# 检查当前用户是否为 super user
check_uid

################################################################################
# 安全检查
# 检查是否有和 loop 文件绑定的 loop 设备,
# 如果有, 是否该 loop 设备以及被挂载
pre_install() {
    local status=$(df --all | grep ${loop_file_mount_point})
    if [ -n "$status" ]; then
        # 绑定并挂载
        log "${loop_file} has been bind and mount"
        log "$(echo $status | awk '{print $1, "<->" ,$6}')"
        exit 0
    else
        local status=$(losetup --associated ${loop_file})
        if [ -n "${status}" ]; then
            # 未挂载但绑定
            used_loop_device=$(echo ${status} | awk -F: '{print $1}')
            log "${loop_file} has been bind, but not mount"
            log "${status}"
            # 挂载已经存在的 loop 设备
            [ ! -e  ${loop_file_mount_point} ] && mkdir ${loop_file_mount_point}
            # 改变挂载点权限
            chown root:root ${loop_file_mount_point}
            chmod 644 ${loop_file_mount_point}
            # 挂载 loop 设备
            mount ${used_loop_device} ${loop_file_mount_point}
            log "${used_loop_device} be mount successfully"
            # 持久化挂载记录到 /etc/fstab
            if [ -z "$(cat /etc/fstab | grep ${loop_file_mount_point})" ]; then
                mount_record="${used_loop_device} ${loop_file_mount_point} ext4 defaults 0 0"
                # echo "${mount_record}" >> /etc/fstab
                echo "${mount_record}"
            fi
            exit 0
        fi
    fi
}
# 创建并绑定 loop 到文件到可使用的 loop 设备,并挂载 loop 设备
install() {
    log "creat,bind,mount loop file"
    # 1. 如果不存在 loop 文件则创建
    if [ ! -e ${loop_file} ]; then
        log "create loop file: ${loop_file}, size: ${loop_file_size} MB"
        dd if=/dev/zero of=${loop_file} bs=1M count=${loop_file_size}
    else
        log "the loop file exist: ${loop_file}"
    fi

    # 2. 查找第一个未绑定的 loop 设备
    used_loop_device=$(losetup --find)
    if [ -z ${used_loop_device} ]; then
        log "there is no loop device that can be used"
        exit 1
    fi

    # 3. 绑定 loop 文件和 loop 设备
    log "attach ${used_loop_device} with ${loop_file}"
    losetup ${used_loop_device} ${loop_file}
    if [ $? -ne 0 ]; then
        log "failed attach loop file with loop device: ${loop_file} <-> ${used_loop_device}"
    fi

    # 4. 用 ext4 格式化 loop 设备
    log "format loop device with ext4 filesystem"
    mkfs.ext4 ${used_loop_device}
    if [ $? -ne 0 ]; then
        log "failed format loop device with ext4 filesystem"
    fi

    # 5. 挂载 loop 设备
    [ ! -e  ${loop_file_mount_point} ] && mkdir ${loop_file_mount_point}
    # 改变挂载点权限
    chown root:root ${loop_file_mount_point}
    chmod 644 ${loop_file_mount_point}
    log "mount loop device at: ${loop_file_mount_point}"
    mount ${used_loop_device} ${loop_file_mount_point}
    if [ $? -ne 0 ]; then
        log "failed mount loop device at: ${loop_file_mount_point}"
    fi

    # 6. 持久化挂载记录到 /etc/fstab
    if [ -z "$(cat /etc/fstab | grep ${loop_file_mount_point})" ]; then
        mount_record="${used_loop_device} ${loop_file_mount_point} ext4 defaults 0 0"
        echo "${mount_record}" >> /etc/fstab
    fi
}

# 卸载 loop 设备并解绑 loop 文件
uninstall() {
    log "uninstall mysql loop file and free loop device"

    # 1. 检查是否存在挂载
    local status=$(df --all | grep ${loop_file_mount_point})
    if [ -z "$status" ]; then
        log "it's no need to umount"
    else
        used_loop_device=$(echo $status | awk '{print $1}')
        log "umount ${used_loop_device}"
        umount ${used_loop_device}
        if [ $? -ne 0 ]; then
            log "failed umount ${used_loop_device}"
        else
            # 从 /etc/fstab 删除挂载记录
            log "remove mount reocrd from /etc/fstab"
            sed -i "#$used_loop_device#d" /etc/fstab
        fi
    fi
    # 2. 删除挂载点
    log "delete mount point: ${loop_file_mount_point}"
    rm -rf ${loop_file_mount_point}

    # 3. 检查是否存在绑定
    local status=$(losetup --associated ${loop_file})
    if [ -z "${status}" ]; then
        log "it's no need to detach ${loop_file}"
    else
        log "detach ${used_loop_device} with ${loop_file}"
        used_loop_device=$(echo $status | awk -F: '{print $1}')
        losetup --detach ${used_loop_device}
        if [ $? -ne 0 ]; then
            log "failed detach ${used_loop_device} with ${loop_file}"
        fi
    fi

    # 3. 保存 loop 文件用以持久化数据
}
################################################################################
# 执行入口
case $1 in
    install)
        pre_install
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        help
        ;;
esac
################################################################################
