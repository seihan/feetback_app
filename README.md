# Feet <img src="assets/logo.png" height="40"> Back

A sensory prosthesis for the feet.

## Purpose

This project aims to develop a sensory prosthesis for the foot.
The target group is people with limited perception of their feet as a result of paralysis or illness.

And people who are looking for ways to develop synaesthetic applications. 

## How it works

The pressure under the feet is recorded by sensors and output as feedback through vibrations on the upper body.

Sensor -> App -> Actor

### Details

Bluetooth low energy devices are connected via the app. Continuous reading of the sensors, evaluation and output to actuators is the main mode of operation. 

## Parts

* 2 pressure resistive soles
* 2 fitness tracker with vibrations
* 1 smartphone

## Framework

Flutter

## Platforms

* Android, min SDK 21 (Android 7)

## Supported Devices

### Actors

Currently only one device is supported. The code base is prepared to add more.

#### MPOW DS-D6

Available on eBay and other stores.

<img src="https://static-data2.manualslib.com/product-images/ae3/1365287/mpow-ds-d6-fitness-electronics.jpg" height=501 alt="MPOW DS-D6 fintess tracker">

*Source: manualslib.com*

This device is well known from other reverse engineering projects. No customized firmware is required for this purpose. The essential function is vibration. Three vibration pulses of different lengths can be sent. The two pulses with the minimum and maximum length are used to represent two different regions on the foot.

### Sensors

Currently are two devices supported. One is still under development and the other is not always available in the EU.

#### FSRTEC - under development

Piezo resistive insole with 12 sensor points. 

[Wearable FSR Sensor](https://www.fsrtek.com/flexible-gait-analysis-piezoresistive-insole-force-sensitive-resistor)

<img src="https://www.fsrtek.com/wp-content/uploads/2021/06/5%E9%9E%8B%E5%9E%AB%EF%BC%881%EF%BC%89.jpg" height=501 alt="FSRTEK fsr sensor">

*Source: fsrtek.com*

This device is **fully** supported.

Thanks to the support from this company.

#### SALTED

Piezo resistive insole with 4 sensor points, vibration output, accelerometer, gyroscope.

[SALTED Golf Insoles](https://en.salted.shop/#none)

<img src="https://simulatedsports.ie/wp-content/uploads/2023/08/f7431c_005422dd57544adb8f1cb68e12412602_mv2.webp" alt="Salted Golf">

*Source: simulatedsports.ie*

This device is **partly** supported.

This sensor was integrated by reverse engineering. 
So far following tasks are working:
* Connect
* Switch on Notify
* Interpret values - wip

Not working or tested
* Vibration output
* Accelerometer readings
* Gyroscope readings

Due to the high price of this product, only the necessary functions were researched. The hcidump of the original app was evaluated for this purpose. The connection setup and the start/stop commands for notify are known.
No try and error attempt was made due to the risk of bricking the device

The exact transmission protocol is unknown. About 80% of the incoming values cannot be interpreted. The detected sensor values are in a narrow range. In addition, a change in the value range appears to occur from a certain pressure. This jump has not yet been systematically recorded and interpreted. Any help on this topic is very welcome.

## Code Details

### Connection

Inside *BluetoothConnectionModel* everything ble related is handled. Special ble commands are stored inside the *PeripheralConstants*.

### Parsing

The incoming ble notify values are converted to sensor values in the SensorStateModel. For uniform use of different sensor types, the sensor values are normalized to the range from 0 to 1.

### Transmission

The *TransmissionHandler* listens for incoming sensor values and writes to the actor devices. The timing and selection of write commands is orchestrated using the *FeedbackModel*.
