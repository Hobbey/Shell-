#!/bin/bash
JBOSS_DIR="/usr/local/jboss-as-7.1.1.Final1"
FILE_DIR="/root/"
FILE_NAME="appStoreNew.war"
BACKUP_DIR="${JBOSS_DIR}/standalone/"

usage () {
    echo "$(basename $0):"
    echo "1 | start                :jboss_start"
    echo "2 | stop                 :jboss_stop"
    echo "3 | update               :jboss_update"
    echo "4 | rollback             :list old version"
    echo "4 | rollback filename    :jboss_rollback filename"
    echo "-t                       :tail nohup.out"
    echo "-t -f                    :tail -f nohup.out"
    echo "-h                       :help info"
}

check_jboss_running () {
    ##### check_jboss_running_pid,check_jboss_running_status
    
    #####
    check_jboss_running_pid=$(ps -ef | grep "${JBOSS_DIR}" | grep -v "grep" | awk '{print $2}')
    if [[ $check_jboss_running_pid =~ ^[0-9]+$ ]]; then
        check_jboss_running_status=1    #在运行
    else
        check_jboss_running_status=0    #未运行
    fi
    
#    echo -e "${check_jboss_running_pid}\n${check_jboss_running_status}"
}

jboss_start () {
    if [[ $check_jboss_running_status -eq 1 ]]; then
        echo "Jboss is running"
        exit 1
    else
        cd ${JBOSS_DIR}/bin/
        nohup ./standalone.sh >> nohup.out 2>&1 &
        sleep 2
        tail -f nohup.out
    fi
}

jboss_stop () {
    if [[ $check_jboss_running_status -eq 0 ]]; then
        echo "Jboss already stoped"
        exit 1
    else
        kill -9 $check_jboss_running_pid
        echo "Jboss is killed"
        rm -rf ${JBOSS_DIR}/standalone/tmp/vfs/temp*
        rm -rf ${JBOSS_DIR}/standalone/tmp/vfs/deployment*
        mv ${JBOSS_DIR}/bin/nohup.out ${JBOSS_DIR}/bin/nohup.out.${DATE}
        sleep 2
        ps -ef | grep jboss | grep -v "grep"
    fi
}

jboss_update () {
    if [[ -f ${FILE_DIR}/${FILE_NAME} ]]; then
        if [[ $check_jboss_running_status -eq 1 ]]; then
            echo "Jboss is running"
            exit 1
        fi
        mv ${JBOSS_DIR}/standalone/deployments/${FILE_NAME} ${BACKUP_DIR}/${FILE_NAME}.$(date +%Y-%m-%d_%H_%M_%S)
        cp ${FILE_DIR}/${FILE_NAME} ${JBOSS_DIR}/standalone/deployments/
        echo "cp ${FILE_DIR}/${FILE_NAME} to ${JBOSS_DIR}/standalone/deployments/ OK"
    else
        echo "${FILE_DIR}/${FILE_NAME} not exist"
    fi
}

jboss_rollback () {
    if [[ -f ${BACKUP_DIR}/"$2" ]]; then
        if  [[ $check_jboss_running_status -eq 1 ]]; then
            echo "Jboss is running"
            exit 1
        fi
        mv ${JBOSS_DIR}/standalone/deployments/${FILE_NAME} ${BACKUP_DIR}/${FILE_NAME}.$(date +%Y-%m-%d_%H_%M_%S)
        cp ${BACKUP_DIR}/$2 ${JBOSS_DIR}/standalone/deployments/${FILE_NAME}
        echo "rollback $2 OK"
    else
        ls -lsh ${BACKUP_DIR}/${FILE_NAME}*
    fi
}

check_jboss_running

case $1 in
    1 | start)
        jboss_start
        ;;
    2 | stop)
        jboss_stop
        ;;
    3 | update)
        jboss_update
        ;;
    4 | rollback)
        jboss_rollback
        ;;
    -h)
        usage
        ;;
    -t)
        if [[ $check_jboss_running_status -eq 0 ]]; then
            echo "Jboss stoped"
            exit
        fi
        if [[ "$2" == "-f" ]]; then
            tail -f ${JBOSS_DIR}/bin/nohup.out
        else
            tail ${JBOSS_DIR}/bin/nohup.out
        fi
        ;;
    *)
        echo "use $(basename $0) -h for help"
esac



vim /home/script/Jboss_control.sh


chown jboss:jboss ${FILE_DIR}/${FILE_NAME}
su jboss -c 'nohup ./standalone.sh >> nohup.out 2>&1 &'

