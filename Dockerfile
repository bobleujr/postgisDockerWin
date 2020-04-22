FROM mcr.microsoft.com/windows/servercore:ltsc2019
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# To install different versions of PostgreSQL, 
# please find a .exe of your choice in 
# and replace the link below (https://get.enterprisedb.com/postgresql/postgresql-9.6.10-2-windows-x64.exe)
RUN [Net.ServicePointManager]::SecurityProtocol = 'Tls12, Tls11, Tls' ; \
    Invoke-WebRequest -UseBasicParsing -Uri 'https://get.enterprisedb.com/postgresql/postgresql-9.6.10-2-windows-x64.exe' -OutFile 'postgresql-installer.exe' ; \
    Start-Process postgresql-installer.exe -ArgumentList '--mode unattended --superpassword password' -Wait ; \
    Remove-Item postgresql-installer.exe -Force

# To install different versions of PostGIS, 
# please find a .zip of your choice in 
# MAKE SURE VERSIONS ARE COMPATIBLE
# and replace
# 1 - the link below (http://download.osgeo.org/postgis/windows/pg96/postgis-bundle-pg96-3.0.1x64.zip)
# 2 - the paths
#   2.1 - C:\\postgis-bundle-pg96-3.0.1x64\\* will follow the version of your bundle (e.g. pg96-2.5.1x64 will be C:\\postgis-bundle-pg96-2.5.1x64\\*)
#   2.2 - C:\\Program Files\\PostgreSQL\\9.6\\ will follow your PostgreSQL version - (e.g. PostgresSQL 12.0 will be C:\\Program Files\\PostgreSQL\\12.0\\)
RUN [Net.ServicePointManager]::SecurityProtocol = 'Tls12, Tls11, Tls' ; \
    Invoke-WebRequest -UseBasicParsing -Uri 'http://download.osgeo.org/postgis/windows/pg96/postgis-bundle-pg96-3.0.1x64.zip' -OutFile 'C:\\postgis.zip' ; \
	Expand-Archive 'C:\\postgis.zip' -DestinationPath 'C:\\' ; \
	Copy-Item -Path 'C:\\postgis-bundle-pg96-3.0.1x64\\*' -Destination 'C:\\Program Files\\PostgreSQL\\9.6\\' -Recurse -Force -Verbose ; \
	Remove-Item -Force -Recurse -Confirm:$false 'C:\\postgis.zip', 'C:\\postgis-bundle-pg96-3.0.1x64'

RUN Invoke-WebRequest -UseBasicParsing -Uri 'https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.3/ServiceMonitor.exe' -OutFile 'ServiceMonitor.exe'

SHELL ["cmd", "/S", "/C"]

# ATTENTION - Don't forget to change this to match your PostgeSQL version
RUN setx /M PATH "C:\\Program Files\\PostgreSQL\\9.6\\bin;%PATH%" && \	
    setx /M DATA_DIR "C:\\Program Files\\PostgreSQL\\9.6\\data" && \
    setx /M PGPASSWORD "password"
    
RUN powershell -Command "Do { pg_isready -q } Until ($?)" && \
    echo listen_addresses = '*' >> "%DATA_DIR%\\postgresql.conf" && \
    echo host  all  all  0.0.0.0/0  trust >> "%DATA_DIR%\\pg_hba.conf" && \
    echo host  all  all  ::0/0      trust >> "%DATA_DIR%\\pg_hba.conf" && \
    net stop postgresql-x64-9.6

EXPOSE 5432

# ATTENTION - Don't forget to change this to match your PostgeSQL version
CMD ["ServiceMonitor.exe", "postgresql-x64-9.6"]
