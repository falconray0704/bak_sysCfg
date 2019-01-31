#!/bin/bash

set -o nounset
set -o errexit

#set -x

apply_newest_config_func()
{
    echo "nginx -s reload"
}

run_stop_immediately_func()
{
    echo "nginx -s stop"
}

run_stop_gracefully_func()
{
    echo "nginx -s quit"
}

tips_configs_func()
{
    echo ""
    echo "Verify configuration file:"
    echo "nginx -t"
    echo ""
    echo "Reload newest configs:"
    apply_newest_config_func
    echo ""
    echo "Stop nginx immediately, no matter have any visitor or not:"
    run_stop_immediately_func
    echo ""
    echo "Stop nginx immediately, waiting all visitors finish:"
    run_stop_gracefully_func
    echo ""
}

tips_operations_func()
{
    echo "Reload newest configs:"
    apply_newest_config_func
    echo ""
    echo "Stop nginx immediately, no matter have any visitor or not:"
    run_stop_immediately_func
    echo ""
    echo "Stop nginx immediately, waiting all visitors finish:"
    run_stop_gracefully_func
    echo ""
}

tips_logs_func()
{
    echo "Reload log file:"
    echo "nginx -s reopen"
}

tips_help_func()
{
    echo "Supported tips:"
    echo '001) [cfg] Tips for configurations.'
    echo '002) [opt] Tips for operations.'
    echo '003) [log] Tips for logs.'
}

[ $# -lt 1 ] && tips_help_func && exit

case $1 in
    help) echo "Tips for docker manipulations:"
        tips_help_func
        ;;
    cfg) echo "001) Tips for configurations:"
        tips_configs_func
        ;;
    opt) echo "002) Tips for operations:"
        tips_operations_func
        ;;
    log) echo "003) Tips for logs:"
        tips_logs_func
        ;;
    *) echo "Unknown cmd: $1"
esac


