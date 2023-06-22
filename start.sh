IF [ "$IS_MASTER" == "true" ]
THEN
	./distribute.sh
ELSE
	./generate.sh
FI