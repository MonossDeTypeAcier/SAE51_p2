docker run \
	-v /root/SAE51_p2/logAlloy/alloy/:/etc/alloy/ \
	-p 12345:12345 \
	grafana/alloy:latest \
		run --server.http.listen-addr=0.0.0.0:12345 --storage.path=/var/lib/alloy/data \
		/etc/alloy/config.alloy
