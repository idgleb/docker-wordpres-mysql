# Como subir la imagen Docker a Google Cloud Run y conectarla con Cloud SQL (WordPress)

Para subir esta imagen de **WordPress** a **Google Cloud Run** y conectarla con **Cloud SQL**, debes seguir varios pasos clave que incluyen configurar la instancia de Cloud SQL, la construcción de la imagen Docker, subirla a **Google Container Registry (GCR)**(**Artifact Registry**), y finalmente desplegar el contenedor en **Cloud Run** con acceso seguro a la base de datos. Te explico cómo hacerlo paso a paso:

## Paso 1: Configurar Cloud SQL

1. Asegúrate de tener una instancia de **Cloud SQL** para **MySQL** disponible y lista. Deberás configurar la red de Cloud SQL para aceptar conexiones privadas de tu servicio en **Cloud Run**.
2. Navega a la **Consola de Google Cloud** y ve a la sección **SQL** https://console.cloud.google.com/sql.
3. Crea una nueva instancia de Cloud SQL (si no lo has hecho ya).
   
   ![image](https://github.com/user-attachments/assets/9ebbca3c-f2e3-464a-93d5-2b5a878b9ebb)
   
- **Parámetros mínimos** si solo deseas probar:
  
  ![image](https://github.com/user-attachments/assets/6094e171-2f39-490e-bf73-22ecabae7f6c)
  
- escribe cualquier ID y contraseña para esta instancia.
  
  ![image](https://github.com/user-attachments/assets/d7989ddb-0e2a-4a19-86bf-48fc1a88b250)

4. En la sección **Connections**, elige **Private IP**, selecciona la red **default**, y presiona el botón **SET UP CONNECTION** (Esto permitirá la conexión desde Cloud Run a Cloud SQL):
   
   ![image](https://github.com/user-attachments/assets/adf1a6e9-77c7-4684-8f16-69c48495db1d)

5. Elige **default-ip-range** para este conneccion de servicio:   
   
   ![image](https://github.com/user-attachments/assets/15d807f2-5d7c-4c1b-878e-5c91ee571f04)

   Ahora guarda todos los cambios que hicimos precionando el boton abajo.


6. Cuando instancia de Cloud SQL esta creada, ve a la sección **Databases**:

   ![image](https://github.com/user-attachments/assets/f6ca6042-c21e-4742-8d63-b64a2d55a29d)

   - Crea la base de datos con nombre **wordpress** (como lo usaste en el Dockerfile).
     
7. Luego ve a la sección **Users** y crea el usuario:
   - **Nombre de usuario**: `wordpress`
   - **Contraseña**: `idgleb123`

     ![image](https://github.com/user-attachments/assets/5397b603-f342-48a7-be0e-09d72456790d)


## Paso 2: Construir la Imagen de Docker

(En este proyecto uso una imagen de **WordPress**, pero puedes usar cualquier otra imagen Docker).

1. Antes de construir la imagen, cambia la IP de la variable **`WORDPRESS_DB_HOST`** en el Dockerfile. Esta variable indica la IP para conectar WordPress (o cualquier otra aplicación) con la base de datos que creamos anteriormente.
   
   - Puedes encontrar la **IP de la base de datos** creada en la sección **Connections** de tu instancia de **Cloud SQL**.

     ![image](https://github.com/user-attachments/assets/fa448ed1-636d-482c-9999-ce6dcf85b4a6)

2. Necesitas construir la imagen de Docker en tu máquina local basada en el Dockerfile proporcionado.
    
   Ingresa esa IP en el Dockerfile. Vos tenes su propio IP.

   ![image](https://github.com/user-attachments/assets/fd179f11-d8ef-4253-acf9-9b73ef43c99b)

   - Después podrás cambiarlo en **Cloud Run** pasando variables de entorno (mediante una reimplementación de imagen).
     
3. Ahora podemos crear la imagen:
   - Navega en la terminal al directorio que contiene tu Dockerfile y ejecuta el siguiente comando:
     ```
     docker build -t gcr.io/PROJECT_ID/wordpress-app:latest .
     ```
   - **`PROJECT_ID`**: ID de tu proyecto en Google Cloud. Puedes obtenerlo aquí: [Dashboard del Proyecto](https://console.cloud.google.com/projectselector2/home/dashboard?organizationId=0&supportedpurview=project).
     
   - En mi caso, ejecuté:
     ```
     docker build -t gcr.io/intense-vault-442413-d0/wordprs2:v1 .
     ```

## Paso 3: Autenticar Docker con Google Container Registry

Necesitas autenticar Docker para poder empujar la imagen a **Google Container Registry (GCR)**. En la terminal, ejecuta este comando:
```bash
gcloud auth configure-docker
```
Esto configurará Docker para autenticar automáticamente los registros de Google Cloud.

## Paso 4: Subir la Imagen a Google Container Registry

Una vez que hayas construido la imagen, súbela a **GCR**:
```bash
docker push gcr.io/[PROJECT_ID]/wordpress-app:latest
```
- En mi caso, ejecuté:
  ```bash
  docker push gcr.io/intense-vault-442413-d0/wordprs2:v1
  ```
Puedes verificar que la imagen se haya subido correctamente navegando a [Google Container Registry](https://console.cloud.google.com/gcr/images) y seleccionando tu proyecto.

![image](https://github.com/user-attachments/assets/08e814cd-7d5b-4203-9a82-62478ffb0c73)


## Paso 5: Desplegar la Aplicación en Google Cloud Run

1. Ahora puedes desplegar la aplicación en **Cloud Run**. Ve a [Google Cloud Run](https://console.cloud.google.com/run) y presiona **IMPLEMENTAR CONTENEDOR** → **Servicio**.

   ![image](https://github.com/user-attachments/assets/0bfb931b-9f3a-4c20-81c5-e1a38b83a4da)

2. Establece las configuraciones (elige la imagen y la instancia de base de datos, y crea una cuenta de servicio):

   ![image](https://github.com/user-attachments/assets/581a6ed8-1e91-46ad-9b99-b811f33dfdea)

   ![image](https://github.com/user-attachments/assets/61c78ca8-1e93-4b35-b58d-cdafc85b8566)

   ![image](https://github.com/user-attachments/assets/92771b9d-4ddd-49bf-8b32-da7a9728b285)

   ![image](https://github.com/user-attachments/assets/eba13140-d59a-46d2-8366-dae1a8c31dce)

   ![image](https://github.com/user-attachments/assets/7e7363a2-8ff9-411b-846a-b155e3a630e6)



3. En la pestaña **RED (NETWORKING)**, elige la configuración para conectar este servicio a la misma **RED** que la instancia de base de datos.

   ![image](https://github.com/user-attachments/assets/affd6bd4-f6d3-44c6-87eb-0e28f46c64f6)

4. En la pestaña **SEGURIDAD**, crea una **cuenta de servicio**(SERVICE ACCOUNT):

   ![image](https://github.com/user-attachments/assets/6acda1c9-1462-4897-b722-4c5b782413bb)

   - Elige el rol **Cloud SQL Client**:

     ![image](https://github.com/user-attachments/assets/84084f5e-b343-455e-b1f7-2fc11275003a)


5. Presiona **CREATE**.

   ![image](https://github.com/user-attachments/assets/6486182c-9201-4be9-98ce-41a27433ba24)


### Y LISTO!!!

Este es el enlace de la aplicación (en mi caso WordPress). Puedes accederla desde Internet:

![image](https://github.com/user-attachments/assets/3889647c-5edc-4878-b20e-a07bdb0c6302)



[https://wordprs2-6610447851.us-central1.run.app](https://wordprs2-6610447851.us-central1.run.app)

Al visitar este enlace, deberías ver que todo funciona: nuestro contenedor Docker está trabajando dentro de **Google Cloud Run** y está conectado con la instancia de la base de datos en **Cloud SQL**.

![image](https://github.com/user-attachments/assets/bf8731c6-f238-4b48-b716-caaa6b5f75c7)



