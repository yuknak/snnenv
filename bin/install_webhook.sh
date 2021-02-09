#!/bin/bash -x

#SECRET=$(ruby -rsecurerandom -e 'puts SecureRandom.hex(20)')

sed s/GENERATED_HMAC_SECRET//g templates/webhook.service > webhook.service
sed -i s#OPENDAX_DIRECTORY#${PWD}#g webhook.service

echo "Generated Secret: ${SECRET}"

sudo mv ./webhook.service /etc/systemd/system/webhook.service
sudo systemctl daemon-reload
sudo systemctl start webhook
