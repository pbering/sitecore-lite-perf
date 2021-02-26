# escape=`

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE
ARG TOOLS_IMAGE

FROM ${SOLUTION_IMAGE} as solution
FROM ${TOOLS_IMAGE} as tools
FROM ${PARENT_IMAGE}

ARG BUILD_CONFIGURATION

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR C:\inetpub\wwwroot

COPY --from=tools C:\tools C:\tools
COPY --from=solution /artifacts/platform/ ./

RUN & 'C:\\tools\\scripts\\Invoke-XdtTransform.ps1' -Path '.\\Web.config' -XdtPath ('C:\\inetpub\\wwwroot\\Web.{0}.config' -f $env:BUILD_CONFIGURATION); `
    Remove-Item -Path '.\\Web.*.config' -Force;

RUN Remove-Item -Path '.\\App_Config\\Include\\Sitecore.Owin.Authentication.IdentityServer.config'