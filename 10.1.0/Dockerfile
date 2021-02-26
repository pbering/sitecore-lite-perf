# escape=`

ARG BUILD_IMAGE

FROM ${BUILD_IMAGE} AS nuget-prep
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY *.sln nuget.config Directory.Build.targets Packages.props /nuget/
COPY src/ /temp/
RUN Invoke-Expression 'robocopy C:/temp C:/nuget/src /s /ndl /njh /njs *.csproj *.scproj packages.config'

FROM ${BUILD_IMAGE} AS builder
ARG BUILD_CONFIGURATION
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /build

COPY --from=nuget-prep ./nuget ./

ENV NUGET_XMLDOC_MODE=skip
RUN msbuild -t:Restore -p:RestorePackagesConfig=true -m -v:m -noLogo

COPY src/ ./src/

RUN msbuild -p:Configuration=$($env:BUILD_CONFIGURATION) `
            -p:Platform=AnyCPU `
            -p:DeployOnBuild=True `
            -p:PublishProfile=Local `
            -p:CollectWebConfigsToTransform=False `
            -p:TransformWebConfigEnabled=False `
            -p:AutoParameterizationWebConfigConnectionStrings=False `
            -r:False -m -v:m -noLogo .\src\platform\Platform.csproj

FROM mcr.microsoft.com/windows/nanoserver:1809
WORKDIR /artifacts
COPY --from=builder /build/docker/deploy/platform  ./platform/
