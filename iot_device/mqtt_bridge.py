import paho.mqtt.client as mqtt
import requests
import json
import sys
import time
import os


MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC = "fisi/smat/estaciones/+/lecturas"


API_URL = os.environ.get(
    "API_URL",
    "http://localhost:8000/lecturas/"
)


JWT_TOKEN = os.environ.get(
    "JWT_TOKEN",
    ""
)


ultimo_valor_por_estacion = {}
ultimo_envio_por_estacion = {}

# ==========================================
# CONEXIÓN MQTT
# ==========================================

def on_connect(client, userdata, flags, rc):

    if rc == 0:

        print("🟢 Conectado exitosamente al Broker MQTT")

        client.subscribe(MQTT_TOPIC)

        print(
            f"📡 Escuchando transmisiones en el tópico: {MQTT_TOPIC}"
        )

    else:

        print(
            f"🔴 Error de conexión al Broker. Código: {rc}"
        )

        sys.exit(1)


def on_message(client, userdata, msg):

    try:

        payload_raw = msg.payload.decode("utf-8")

        data_json = json.loads(payload_raw)

        topic_parts = msg.topic.split('/')

        estacion_id = int(topic_parts[3])

        valor_actual = float(data_json["valor"])

        print(
            f"\n📩 Estación [{estacion_id}] -> {valor_actual}"
        )

        ahora = time.time()

        ultimo_valor = ultimo_valor_por_estacion.get(
            estacion_id
        )

        ultimo_envio = ultimo_envio_por_estacion.get(
            estacion_id,
            0
        )

        enviar = False

        # ==================================
        # PRIMERA LECTURA
        # ==================================

        if ultimo_valor is None:

            print(
                "🆕 Primera lectura de la estación"
            )

            enviar = True

        else:

            # ==============================
            # VARIACIÓN
            # ==============================

            if ultimo_valor == 0:

                porcentaje_cambio = 100

            else:

                porcentaje_cambio = abs(
                    (valor_actual - ultimo_valor)
                    / ultimo_valor
                ) * 100

            tiempo_transcurrido = (
                ahora - ultimo_envio
            )

            print(
                f"📊 Cambio detectado: "
                f"{porcentaje_cambio:.2f}%"
            )


            if porcentaje_cambio > 5:

                print(
                    "✅ Cambio superior al 5%"
                )

                enviar = True


            elif tiempo_transcurrido > 60:

                print(
                    "⏰ Reporte periódico de vida (60s)"
                )

                enviar = True

        # ==================================
        # FILTRADO
        # ==================================

        if not enviar:

            print(
                "🚫 Petición HTTP bloqueada por Deadband Filter"
            )

            return


        api_payload = {

            "valor": valor_actual,

            "estacion_id": estacion_id
        }

        headers = {

            "Content-Type": "application/json",

            "Authorization":
            f"Bearer {JWT_TOKEN}"
        }

        response = requests.post(
            API_URL,
            json=api_payload,
            headers=headers
        )

        if response.status_code in [200, 201]:

            print(
                f"💾 Lectura guardada correctamente"
            )

            ultimo_valor_por_estacion[
                estacion_id
            ] = valor_actual

            ultimo_envio_por_estacion[
                estacion_id
            ] = ahora

        else:

            print(
                f"⚠️ API rechazó el dato "
                f"({response.status_code})"
            )

            print(response.text)

    except KeyError as e:

        print(
            f"❌ Falta la llave {e} en el payload"
        )

    except ValueError:

        print(
            "❌ Valor o estación inválidos"
        )

    except Exception as e:

        print(
            f"❌ Error crítico: {e}"
        )

# ==========================================
# MQTT
# ==========================================

bridge_client = mqtt.Client()

bridge_client.on_connect = on_connect

bridge_client.on_message = on_message

try:

    print(
        "🚀 Inicializando Bridge SMAT..."
    )

    bridge_client.connect(
        MQTT_BROKER,
        MQTT_PORT,
        60
    )

    bridge_client.loop_forever()

except KeyboardInterrupt:

    print(
        "\n🛑 Bridge detenido por el administrador."
    )