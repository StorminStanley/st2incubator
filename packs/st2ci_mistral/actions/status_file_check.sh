FILE=$1

if [[ -f $FILE ]]
then
    rm -f $FILE
    echo "Mistral itests succeeded."
    exit 0
fi

echo "Mistral itests failed. Look at what action failed and debug."
exit 1
