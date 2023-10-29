#!/bin/bash

# Author
# original author:https://github.com/gongzili456
# modified by:https://github.com/haoel
# modified by:https://github.com/meiyingqishi

# Ubuntu 22.04 系统环境

COLOR_ERROR="\e[38;5;198m"
COLOR_NONE="\e[0m"
COLOR_SUCC="\e[92m"

update_core(){
    echo -e "${COLOR_ERROR}当前系统内核版本太低 <$VERSION_CURR>,需要更新系统内核.${COLOR_NONE}"
    sudo apt install -y -qq --install-recommends linux-generic-hwe-18.04
    sudo apt autoremove

    echo -e "${COLOR_SUCC}内核更新完成,重新启动机器...${COLOR_NONE}"
    sudo reboot
}

check_bbr(){
    has_bbr=$(lsmod | grep bbr)

    # 如果已经发现 bbr 进程
    if [ -n "$has_bbr" ] ;then
        echo -e "${COLOR_SUCC}TCP BBR 拥塞控制算法已经启动${COLOR_NONE}"
    else
        start_bbr
    fi
}

start_bbr(){
    echo "启动 TCP BBR 拥塞控制算法"
    sudo modprobe tcp_bbr
    echo "tcp_bbr" | sudo tee --append /etc/modules-load.d/modules.conf
    echo "net.core.default_qdisc=fq" | sudo tee --append /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee --append /etc/sysctl.conf
    sudo sysctl -p
    sysctl net.ipv4.tcp_available_congestion_control
    sysctl net.ipv4.tcp_congestion_control
}

install_bbr() {
    # 如果内核版本号满足最小要求
    if [[ $VERSION_CURR > $VERSION_MIN ]]; then
        check_bbr
    else
        update_core
    fi
}

install_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo "开始安装 Docker CE"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
        sudo apt-get update -qq
        sudo apt-get install -y docker-ce
    else
        echo -e "${COLOR_SUCC}Docker CE 已经安装成功了${COLOR_NONE}"
    fi
}

install_memos() {
    docker run -d \
        --init \
        --name memos \
        --publish 5230:5230 \
        --volume ~/.memos/:/var/opt/memos \
        ghcr.io/usememos/memos:latest
}

check_container(){
    has_container=$(sudo docker ps --format "{{.Names}}" | grep "$1")

    # test 命令规范： 0 为 true, 1 为 false, >1 为 error
    if [ -n "$has_container" ]; then
        return 0
    else
        return 1
    fi
}

install_gost() {
    if ! [ -x "$(command -v docker)" ]; then
        echo -e "${COLOR_ERROR}未发现Docker，请求安装 Docker ! ${COLOR_NONE}"
        return
    fi

    if check_container gost ; then
        echo -e "${COLOR_ERROR}Gost 容器已经在运行了，你可以手动停止容器，并删除容器，然后再执行本命令来重新安装 Gost。 ${COLOR_NONE}"
        return
    fi

    echo "准备启动 Gost 代理程序,为了安全,需要使用用户名与密码进行认证."
    read -r -p "请输入你要使用的域名：" DOMAIN
    read -r -p "请输入你要使用的用户名:" USER
    read -r -p "请输入你要使用的密码:" PASS
    read -r -p "请输入需要侦听的端口号(8443)：" PORT

    if [[ -z "${PORT// }" ]] || ! [[ "${PORT}" =~ ^[0-9]+$ ]] || ! { [ "$PORT" -ge 1 ] && [ "$PORT" -le 65535 ]; }; then
        echo -e "${COLOR_ERROR}非法端口,使用默认端口 8443 !${COLOR_NONE}"
        PORT=8443
    fi

    BIND_IP=0.0.0.0

    sudo docker run -d --name gost \
        --net=host ginuerzh/gost \
        -L "mwss://${USER}:${PASS}@${BIND_IP}:${PORT}?probeResistance=host:localhost:5230&knock=www.google.com"
}

install_config_nginx() {
    sudo apt install -y nginx

    while true; do
        read -r -p "请输入你要反向代理的域名（输入 out 以退出）：" DOMAIN

        if [[ -z "${DOMAIN// }" ]]; then
            echo "输入不符合要求！"
            continue
        fi

        if [[ "$DOMAIN" == "out" ]]; then
            break
        fi

        sudo touch /etc/nginx/sites-available/${DOMAIN}

        read -r -p "请输入你要反向代理域名的端口：" PORT

        if ! [[ $PORT =~ ^[0-9]+$ && $PORT -ge 1 && $PORT -le 65535 ]]; then
            echo "输入端口号不符合要求！"
            continue
        fi

        echo '
        server {
            server_name '${DOMAIN}';

            location / {
                proxy_pass http://localhost:'${PORT}';
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }
        }
        ' | sudo tee /etc/nginx/sites-available/${DOMAIN}

        sudo ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/${DOMAIN}
    done

    sudo systemctl restart nginx
}

create_cert() {
    if ! [ -x "$(command -v certbot)" ]; then
        sudo apt install certbot
        sudo apt install python3-certbot-nginx
    fi

    while true; do
        read -r -p "请输入你要配置证书的域名（输入 out 以退出）：" DOMAIN

        if [[ -z "${DOMAIN// }" ]]; then
            echo "输入不符合要求！"
            continue
        fi

        if [[ "$DOMAIN" == "out" ]]; then
            break
        fi

        sudo certbot --nginx -d $DOMAIN
    done

    sudo systemctl restart nginx
}

crontab_exists() {
    crontab -l 2>/dev/null | grep "$1" >/dev/null 2>/dev/null
}

create_cron_job(){
    # 写入前先检查，避免重复任务。
    if ! crontab_exists "certbot renew --force-renewal"; then
        echo "0 0 1 * * /usr/bin/certbot renew --force-renewal" >> /var/spool/cron/crontabs/root
        echo "${COLOR_SUCC}成功安装证书renew定时作业！${COLOR_NONE}"
    else
        echo "${COLOR_SUCC}证书renew定时作业已经安装过！${COLOR_NONE}"
    fi

    if ! crontab_exists "docker restart gost"; then
        echo "5 0 1 * * /usr/bin/docker restart gost" >> /var/spool/cron/crontabs/root
        echo "${COLOR_SUCC}成功安装gost更新证书定时作业！${COLOR_NONE}"
    else
        echo "${COLOR_SUCC}gost更新证书定时作业已经成功安装过！${COLOR_NONE}"
    fi
}

init(){
    VERSION_CURR=$(uname -r | awk -F '-' '{print $1}')
    VERSION_MIN="4.9.0"

    OIFS=$IFS  # Save the current IFS (Internal Field Separator)
    IFS=','    # New IFS

    COLUMNS=50
    echo -e "\n菜单选项\n"

    while true
    do
        PS3="Please select a option:"
        re='^[0-9]+$'
        select opt in "安装 TCP BBR 拥塞控制算法" \
                    "安装 Docker 服务程序" \
                    "安装 Memos 备忘录服务程序" \
                    "安装 Gost 代理服务" \
                    "安装并配置 Nginx 反向代理" \
                    "创建 SSL 证书" \
                    "创建证书更新 CronJob" \
                    "退出" ; do

            if ! [[ $REPLY =~ $re ]] ; then
                echo -e "${COLOR_ERROR}Invalid option. Please input a number.${COLOR_NONE}"
                break;
            elif (( REPLY == 1 )) ; then
                install_bbr
                break;
            elif (( REPLY == 2 )) ; then
                install_docker
                break
            elif (( REPLY == 3 )) ; then
                install_memos
                break
            elif (( REPLY == 4 )) ; then
                install_gost
                break
            elif (( REPLY == 5 )) ; then
                install_config_nginx
                break
            elif (( REPLY == 6 )) ; then
                create_cert
                #loop=1
                break
            elif (( REPLY == 7 )) ; then
                create_cron_job
                break
            elif (( REPLY == 8 )) ; then
                exit
            else
                echo -e "${COLOR_ERROR}Invalid option. Try another one.${COLOR_NONE}"
            fi
        done
    done

    echo "${opt}"
    IFS=$OIFS  # Restore the IFS
}

init