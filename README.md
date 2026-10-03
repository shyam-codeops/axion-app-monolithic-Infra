# Axion App -- Monolithic Architecture Deployment

This repository contains the deployment procedure for the **Axion
Intelligence Platform** using a monolithic application architecture on
Azure.

The deployment consists of:

-   Azure infrastructure provisioned with Terraform
-   Azure Database for PostgreSQL
-   PostgreSQL schema and telemetry sample data
-   FastAPI backend running on an Azure VM
-   React/Vite frontend served by Nginx on an Azure VM
-   Frontend-to-backend communication over the backend VM public IP and
    port `8000`

------------------------------------------------------------------------

## Architecture

``` text
                         Internet
                            |
                            v
                +-----------------------+
                |   Frontend VM         |
                |   Nginx :80           |
                |   React / Vite        |
                +-----------+-----------+
                            |
                            | HTTP :8000
                            v
                +-----------------------+
                |   Backend VM          |
                |   FastAPI / Uvicorn   |
                |   :8000               |
                +-----------+-----------+
                            |
                            | PostgreSQL :5432
                            v
                +-----------------------+
                | Azure PostgreSQL      |
                | axiondb               |
                +-----------------------+
```

------------------------------------------------------------------------

# 1. Provision Infrastructure with Terraform

Infrastructure is provisioned using Terraform.

Repository:

``` text
https://github.com/shyam-codeops/axion-app-monolithic-Infra.git
```

Clone the infrastructure repository:

``` bash
git clone https://github.com/shyam-codeops/axion-app-monolithic-Infra.git
cd axion-app-monolithic-Infra
```

Use the appropriate Terraform environment and variables for the
deployment.

> Keep Terraform variable files containing credentials private. Do not
> commit secrets to the repository.

------------------------------------------------------------------------

# 2. Configure PostgreSQL with pgAdmin 4

Install and open **pgAdmin 4**.

In pgAdmin:

1.  Right-click **Servers**
2.  Select **Register → Server**
3.  Enter any server name
4.  Open the **Connection** tab

The Azure PostgreSQL endpoint should be used as the hostname.

Example:

``` text
postgresql-axion-dev-01.postgres.database.azure.com
```

Use the PostgreSQL username and password configured for the Terraform
environment.

## Allow the Client IP

Before saving the pgAdmin connection:

1.  Open the Azure Portal.
2.  Open the PostgreSQL server.
3.  Go to **Networking**.
4.  Add the current client/public IP of the machine running pgAdmin to
    the PostgreSQL firewall rules.
5.  Save the firewall rule.
6.  Return to pgAdmin and save the server connection.

The PostgreSQL server should then appear in pgAdmin.

------------------------------------------------------------------------

# 3. Create the Telemetry Database Schema

Database schema repository:

``` text
https://github.com/devopsinsiders/axion-database-schema.git
```

Open:

``` text
02-telemetry.sql
```

In pgAdmin:

1.  Expand the PostgreSQL server.
2.  Open the `axiondb` database.
3.  Right-click **Tables**.
4.  Select **Query Tool**.
5.  Copy the SQL from `02-telemetry.sql`.
6.  Paste it into the Query Tool.
7.  Execute the script.
8.  Refresh the database.

The telemetry table and its columns should now be created.

------------------------------------------------------------------------

# 4. Insert Telemetry Sample Data

Open the project's dummy/sample data file.

In pgAdmin:

1.  Open the `axiondb` database.
2.  Open **Query Tool**.
3.  Paste the telemetry sample data.
4.  Execute the query.
5.  Refresh the database.

Verify that the telemetry data is present.

Example:

``` sql
SELECT COUNT(*) FROM telemetry;
```

You can also inspect the latest records:

``` sql
SELECT *
FROM telemetry
ORDER BY timestamp DESC
LIMIT 20;
```

------------------------------------------------------------------------

# 5. Backend Deployment

The backend is the **Axion Telemetry Query Service**.

## SSH into Backend VM

``` bash
ssh <username>@<backend-public-ip>
```

## Clone the backend repository

``` bash
git clone https://github.com/devopsinsiders/axion-telemetry-query-service.git
cd axion-telemetry-query-service
```

## Install Python virtual environment support

``` bash
sudo apt update
sudo apt install -y python3.12-venv
```

## Create and activate the virtual environment

``` bash
python3 -m venv venv
source venv/bin/activate
```

For Windows:

``` powershell
venv\Scripts\activate
```

## Install dependencies

``` bash
pip install -r requirements.txt
```

------------------------------------------------------------------------

# 6. Configure the Backend Database Connection

Open the backend configuration:

``` bash
nano config.py
```

Update the PostgreSQL connection settings.

The configuration should point to:

-   PostgreSQL username
-   PostgreSQL password
-   Azure PostgreSQL hostname
-   PostgreSQL port `5432`
-   Database name `axiondb`

Example format:

``` text
postgresql://<username>:<password>@<postgresql-endpoint>:5432/axiondb
```

### Special character in password

If a PostgreSQL password contains `@`, URL-encode it as `%40`.

Example:

``` text
Nested@1234
```

becomes:

``` text
Nested%401234
```

Also ensure the database host is the Azure PostgreSQL endpoint rather
than `localhost`.

Save the file and verify it:

``` bash
cat config.py
```

> Do not paste or commit real credentials into documentation, Git,
> screenshots, or public repositories.

------------------------------------------------------------------------

# 7. Allow Backend VM Access to PostgreSQL

The Backend VM must be allowed through the Azure PostgreSQL firewall.

In Azure Portal:

1.  Open the PostgreSQL server.
2.  Open **Networking**.
3.  Add the Backend VM's public IP to the firewall rules.
4.  Save the configuration.

The backend VM must be able to connect to PostgreSQL over port `5432`.

------------------------------------------------------------------------

# 8. Allow Backend Port 8000

Allow inbound TCP port `8000` on the Backend VM's Azure Network Security
Group.

Recommended rule:

``` text
Direction: Inbound
Protocol: TCP
Port: 8000
Action: Allow
```

For a production deployment, restrict the source instead of allowing the
port from the entire Internet whenever possible.

------------------------------------------------------------------------

# 9. Start the Backend

From the backend project directory with the virtual environment
activated:

``` bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

The API should now listen on:

``` text
http://<BACKEND-PUBLIC-IP>:8000
```

------------------------------------------------------------------------

# 10. Verify Backend API

## API root

``` bash
curl http://<BACKEND-PUBLIC-IP>:8000/
```

A `404 Not Found` response at `/` can be normal if the FastAPI
application does not define a root route.

## Swagger UI

Open:

``` text
http://<BACKEND-PUBLIC-IP>:8000/docs
```

## ReDoc

Open:

``` text
http://<BACKEND-PUBLIC-IP>:8000/redoc
```

Swagger should display the Axion Telemetry Query Service endpoints.

The documented API includes endpoints such as:

``` text
/dashboard/summary
/devices
/devices/{device_id}/latest
/devices/{device_id}/trends
/devices/top-anomalous
/dashboard/throughput
/dashboard/regions
```

Execute the endpoints from Swagger and confirm that telemetry data is
returned.

If data is returned successfully, the backend is connected to
PostgreSQL.

------------------------------------------------------------------------

# 11. Frontend Deployment

The frontend is the Axion React/Vite application.

## SSH into Frontend VM

``` bash
ssh ssadmin@<frontend-public-ip>
```

## Clone the frontend

``` bash
git clone https://github.com/devopsinsiders/axion-ui.git
cd axion-ui
```

------------------------------------------------------------------------

# 12. Install Node.js 22

``` bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Verify:

``` bash
node -v
npm -v
```

------------------------------------------------------------------------

# 13. Install Frontend Dependencies

``` bash
npm install
```

> Do not run `npm audit fix` as part of this deployment procedure unless
> dependency changes have been reviewed and tested.

------------------------------------------------------------------------

# 14. Configure Backend API URL

This step must be completed **before running the frontend build**.

First check the existing API URL:

``` bash
grep -Rni "api.axionsystems.de" src/
```

The API base URL is used in:

``` text
src/App.tsx
src/components/pages/DashboardView.tsx
src/components/pages/HistoricalTrends.tsx
```

Replace the old API domain with the actual Backend VM public IP and
port.

Example:

``` bash
sed -i 's|https://api.axionsystems.de|http://<BACKEND-PUBLIC-IP>:8000|g' \
src/App.tsx \
src/components/pages/DashboardView.tsx \
src/components/pages/HistoricalTrends.tsx
```

Verify:

``` bash
grep -Rni "<BACKEND-PUBLIC-IP>" src/
```

For the current direct-IP deployment, the API URL should include port
`8000`:

``` text
http://<BACKEND-PUBLIC-IP>:8000
```

### Important

If the backend is exposed directly through Uvicorn on port `8000`, do
**not** omit the port.

Incorrect:

``` text
http://<BACKEND-PUBLIC-IP>
```

Correct:

``` text
http://<BACKEND-PUBLIC-IP>:8000
```

If a reverse proxy is later configured on port `80` or `443`, the
frontend URL can be changed accordingly.

------------------------------------------------------------------------

# 15. Build the Frontend

Run:

``` bash
npm run build
```

Verify the generated build:

``` bash
ls -la dist/
```

Confirm that the backend IP exists in the compiled application:

``` bash
grep -Rqs "<BACKEND-PUBLIC-IP>:8000" dist/ \
&& echo "CORRECT API FOUND" \
|| echo "API NOT FOUND"
```

This check is important because the browser uses the compiled files in
`dist/`, not the source files directly.

------------------------------------------------------------------------

# 16. Install Nginx

``` bash
sudo apt update
sudo apt install -y nginx
```

Check Nginx:

``` bash
sudo systemctl status nginx
```

------------------------------------------------------------------------

# 17. Deploy React/Vite Build to Nginx

Remove the default Nginx content:

``` bash
sudo rm -rf /var/www/html/*
```

Copy the frontend build:

``` bash
sudo cp -r dist/* /var/www/html/
```

Verify:

``` bash
ls -la /var/www/html
```

------------------------------------------------------------------------

# 18. Start / Reload Nginx

``` bash
sudo systemctl enable --now nginx
```

Then:

``` bash
sudo systemctl reload nginx
```

------------------------------------------------------------------------

# 19. Test Nginx Locally

From the Frontend VM:

``` bash
curl -I http://localhost
```

Expected:

``` text
HTTP/1.1 200 OK
Server: nginx
```

------------------------------------------------------------------------

# 20. Allow Frontend HTTP Port 80

On the Frontend VM's Azure Network Security Group, create an inbound
rule:

``` text
Direction: Inbound
Protocol: TCP
Port: 80
Source: Internet
Action: Allow
```

For production, restrict access where appropriate.

------------------------------------------------------------------------

# 21. Access the Axion Application

Open:

``` text
http://<FRONTEND-PUBLIC-IP>
```

The Axion Intelligence Platform login page should appear.

After login, verify:

-   Dashboard
-   Live telemetry
-   Asset hierarchy
-   Historical trends
-   System topology
-   Alarms & events
-   Telemetry throughput
-   Device data

------------------------------------------------------------------------

# 22. End-to-End Validation

The complete data flow should be:

``` text
User Browser
     |
     | HTTP :80
     v
Frontend VM
Nginx
     |
     | API HTTP :8000
     v
Backend VM
FastAPI / Uvicorn
     |
     | PostgreSQL :5432
     v
Azure PostgreSQL
axiondb
     |
     v
telemetry table
```

Validate each layer independently.

### Database

``` sql
SELECT COUNT(*) FROM telemetry;
```

### Backend

``` bash
curl http://<BACKEND-PUBLIC-IP>:8000/docs
```

### Backend API

``` bash
curl http://<BACKEND-PUBLIC-IP>:8000/devices
```

### Frontend

``` bash
curl -I http://localhost
```

### Browser

Open:

``` text
http://<FRONTEND-PUBLIC-IP>
```

------------------------------------------------------------------------

# 23. Troubleshooting

## Frontend loads but no telemetry appears

Check the API URL in source:

``` bash
grep -Rni "API_BASE" src/
```

Check the compiled build:

``` bash
grep -Rqs "<BACKEND-PUBLIC-IP>:8000" dist/ \
&& echo "CORRECT API FOUND" \
|| echo "API NOT FOUND"
```

If the source was changed after the previous build, rebuild and
redeploy:

``` bash
npm run build

sudo rm -rf /var/www/html/*
sudo cp -r dist/* /var/www/html/

sudo systemctl reload nginx
```

Then refresh the browser with:

``` text
Ctrl + F5
```

## Backend cannot be reached

Check Uvicorn:

``` bash
sudo ss -lntp | grep 8000
```

The service should listen on:

``` text
0.0.0.0:8000
```

Check the Azure NSG and ensure TCP `8000` is allowed.

Test:

``` bash
curl -i http://<BACKEND-PUBLIC-IP>:8000/docs
```

## Backend cannot access PostgreSQL

Verify:

-   PostgreSQL firewall allows the Backend VM IP.
-   PostgreSQL hostname is correct.
-   Database name is `axiondb`.
-   Port is `5432`.
-   Credentials are correct.
-   Password special characters are URL-encoded when required.

## `/` returns 404 from FastAPI

This does not necessarily indicate a problem.

If:

``` bash
curl -i http://<BACKEND-PUBLIC-IP>:8000/
```

returns:

``` json
{"detail":"Not Found"}
```

but:

``` bash
curl -i http://<BACKEND-PUBLIC-IP>:8000/docs
```

returns:

``` text
HTTP/1.1 200 OK
```

the FastAPI service is reachable. Test the actual API endpoints listed
in Swagger.

------------------------------------------------------------------------

# 24. Security Considerations

This deployment exposes frontend HTTP port `80` and backend API port
`8000`.

For a production implementation, consider:

-   HTTPS for the frontend.
-   HTTPS for API communication.
-   Reverse proxying the API through Nginx or an Azure service.
-   Restricting backend port `8000` instead of allowing Internet access.
-   Using Azure Key Vault or another secret-management solution.
-   Removing passwords from source/configuration files.
-   Using environment variables for secrets.
-   Restricting PostgreSQL firewall rules to required sources.
-   Using managed identity where supported.
-   Avoiding public exposure of database ports.
-   Rotating any credentials that were previously exposed in
    documentation or screenshots.

------------------------------------------------------------------------

# 25. Useful Commands

### Check frontend API configuration

``` bash
grep -Rni "API_BASE" src/
```

### Check compiled API configuration

``` bash
grep -Rqs "<BACKEND-PUBLIC-IP>:8000" dist/ \
&& echo "CORRECT API FOUND" \
|| echo "API NOT FOUND"
```

### Check Nginx

``` bash
sudo systemctl status nginx
```

### Reload Nginx

``` bash
sudo systemctl reload nginx
```

### Check Nginx locally

``` bash
curl -I http://localhost
```

### Check backend

``` bash
curl -i http://<BACKEND-PUBLIC-IP>:8000/docs
```

### Check backend listener

``` bash
sudo ss -lntp | grep 8000
```

### Check PostgreSQL data

``` sql
SELECT *
FROM telemetry
ORDER BY timestamp DESC
LIMIT 20;
```

------------------------------------------------------------------------

# Repositories

### Infrastructure

``` text
https://github.com/shyam-codeops/axion-app-monolithic-Infra.git
```

### Database Schema

``` text
https://github.com/devopsinsiders/axion-database-schema.git
```

### Backend

``` text
https://github.com/devopsinsiders/axion-telemetry-query-service.git
```

### Frontend

``` text
https://github.com/devopsinsiders/axion-ui.git
```

------------------------------------------------------------------------

## Deployment Summary

  Component           Technology                 Port
  ------------------- ------------------- -----------
  Infrastructure      Terraform                   ---
  Database            Azure PostgreSQL           5432
  Backend             FastAPI + Uvicorn          8000
  Frontend            React/Vite                  ---
  Web Server          Nginx                        80
  API Documentation   Swagger               8000/docs

The original deployment guide documents the Terraform, PostgreSQL,
backend, and frontend stages across the full deployment workflow.
fileciteturn0file0L2-L4 fileciteturn0file0L46-L61
fileciteturn0file0L96-L126
