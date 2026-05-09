function whatsmyip --description 'Show internal and external IP addresses'
    echo -n "Internal IP: "
    ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'
    echo -n "External IP: "
    curl -s https://ifconfig.me
    echo
end
