CREDENTIALS= -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
MUSICBRAINZ_BUCKET=musicbrainz-bucket
MUSICBRAINZ_FILE=musicbrainz-server.ova
IMAGE_DESCRIPTION="MusicBrainz Image"

default:
	docker build -t awscli .

download-latest: # Download from musicbrainz (tried to pipe directly to aws s3 but couldnt get it to work)
	docker run -v `pwd`:/src --rm tutum/curl curl "ftp://vm.musicbrainz.org/pub/musicbrainz-vm/musicbrainz-server-2015-08-06.ova" -o /src/musicbrainz-server.ova

upload-to-s3:
	docker run --rm -v `pwd`:/src $(CREDENTIALS) awscli aws s3 cp /src/musicbrainz-server.ova s3://musicbrainz-bucket/musicbrainz-server.ova

create-vmimport:
	docker run --rm -v `pwd`:/src $(CREDENTIALS) awscli aws iam create-role --role-name vmimport --assume-role-policy-document file:///src/trust-policy.json
	docker run --rm -v `pwd`:/src $(CREDENTIALS) awscli aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file:///src/role-policy.json

start-import-image:
	docker run --rm -v `pwd`:/src $(CREDENTIALS) awscli aws ec2 import-image --platform Linux --architecture x86_64 --description $(IMAGE_DESCRIPTION) --disk-containers file:///src/musicbrainz-server.json --region us-east-1

check-progress:
	docker run --rm -v `pwd`:/src $(CREDENTIALS) awscli aws ec2 describe-import-image-tasks --region us-east-1
