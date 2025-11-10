IMAGE = noble-server-cloudimg-amd64.img

all: $(IMAGE)

$(IMAGE):
	wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
