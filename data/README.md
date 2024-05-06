# Generating Certificates

1. Generate Certificate Signing Request `csr` file. *Be sure to pull existing or push new password to keyvault*.

   ```sh
   openssl req -out data/$env.sslcert.csr \
   -passout file:data/password.txt \
   -newkey rsa:2048 \
   -keyout data/$env.private.key \
   -config data/$env.san.toml
   ```

2. Create CSR signing request from [certificate portal](https://access.gsk.com/certificates/certificates)
3. Download certificate file from portal after it is generated
4. Append chain to certificate for valid cert and save as a `.pem` file
5. Push to cluster secret with `kubectl`

   ```sh
   kubectl create secret tls sonarqube-tls \
   --cert=path/to/cert/file \
   --key=path/to/key/file
   ```
