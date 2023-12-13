#! /bin/bash
#
# Build benchmark image.
cfg=config.inc

set -e


if [[ "$OSTYPE" == "darwin"* ]]
then
    readonly ExecName=$(greadlink -f "$0")
else
    readonly ExecName=$(readlink --canonicalize "$0")
fi


main()
{
    local baseDir=$(dirname "$ExecName")

    . "$baseDir/$cfg"
  
	docker build -t $BENCHMARK_IMAGE -f $baseDir/image/Dockerfile .
	docker push $BENCHMARK_IMAGE
}


main "$@"

