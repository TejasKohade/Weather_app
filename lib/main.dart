import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helloworld/consts/colors.dart';
import 'package:helloworld/consts/images.dart';
import 'package:helloworld/consts/strings.dart';
import 'package:helloworld/controllers/main_controller.dart';
import 'package:helloworld/models/hourly_weather_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';
import 'package:helloworld/utils/our_themes.dart';
import 'models/current_weather_model.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: CustomThemes.lightTheme,
      darkTheme: CustomThemes.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WeatherApp(),
      title: "Weather App",
    );
  }
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    var date = DateFormat("yMMMMd").format(DateTime.now());
    var theme = Theme.of(context);
    var controller = Get.put(MainController());
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: date.text.color(theme.primaryColor).make(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          Obx(
            () => IconButton(
              onPressed: () {
                controller.changeTheme();
              },
              icon: Icon(
                controller.isDark.value ? Icons.light_mode : Icons.dark_mode,
                color: theme.iconTheme.color,
              ),
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
                color: theme.iconTheme.color,
              ))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
          future: controller.currentWeatherData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              CurrentWeather data = snapshot.data;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data.name
                        .toUpperCase()
                        .text
                        .fontFamily("Poppins_Bold")
                        .size(36)
                        .letterSpacing(3)
                        .color(theme.primaryColor)
                        .make(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/weather/${data.weather[0].icon}.png",
                          width: 80,
                          height: 80,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "${data.main.temp}$degree",
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontFamily: "Poppins",
                                    fontSize: 64,
                                  )),
                              TextSpan(
                                  text: data.weather[0].main,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    letterSpacing: 3,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.expand_less_rounded,
                            color: theme.iconTheme.color,
                          ),
                          label: "${data.main.tempMax}$degree"
                              .text
                              .color(theme.iconTheme.color)
                              .make(),
                        ),
                        TextButton.icon(
                          onPressed: null,
                          icon: Icon(
                            Icons.expand_more_rounded,
                            color: theme.iconTheme.color,
                          ),
                          label: "${data.main.tempMin}$degree"
                              .text
                              .color(theme.iconTheme.color)
                              .make(),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        3,
                        (index) {
                          var iconlist = [clouds, humidity, windspeed];
                          var values = [
                            "${data.clouds.all}%",
                            "${data.main.humidity}%",
                            "${data.wind.speed} Km/h"
                          ];
                          return Column(
                            children: [
                              Image.asset(
                                iconlist[index],
                                width: 60,
                                height: 60,
                              )
                                  .box
                                  .gray200
                                  .roundedSM
                                  .padding(const EdgeInsets.all(8))
                                  .make(),
                              10.heightBox,
                              values[index].text.gray400.make(),
                            ],
                          );
                        },
                      ),
                    ),
                    10.heightBox,
                    const Divider(),
                    10.heightBox,
                    FutureBuilder(
                      future: controller.hourlyWeatherData,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          HourlyWeatherData hourlyData = snapshot.data;
                          return SizedBox(
                            height: 150,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: hourlyData.list!.length > 6
                                  ? 6
                                  : hourlyData.list!.length,
                              itemBuilder: (BuildContext context, int index) {
                                var time = DateFormat.jm().format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        hourlyData.list![index].dt!.toInt() *
                                            1000));
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      time.text.gray200.make(),
                                      Image.asset(
                                        "assets/weather/${hourlyData.list![index].weather![0].icon}.png",
                                        width: 80,
                                      ),
                                      "${hourlyData.list![index].main!.temp}$degree "
                                          .text
                                          .white
                                          .make(),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    10.heightBox,
                    const Divider(),
                    10.heightBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "Next 7 days".text.color(theme.primaryColor).make(),
                        TextButton(
                            onPressed: () {}, child: "View All".text.make()),
                      ],
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 7,
                      itemBuilder: (BuildContext context, int index) {
                        var day = DateFormat("EEEE").format(
                          DateTime.now().add(
                            Duration(days: 1 + index),
                          ),
                        );
                        return Card(
                          color: theme.cardColor,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: day.text.semiBold
                                      .color(theme.primaryColor)
                                      .make(),
                                ),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: null,
                                    icon: Image.asset(
                                      "assets/weather/50n.png",
                                      width: 40,
                                    ),
                                    label: "26$degree"
                                        .text
                                        .color(theme.primaryColor)
                                        .make(),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "37$degree /",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontFamily: "Poppins",
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "26$degree",
                                        style: TextStyle(
                                          color: theme.iconTheme.color,
                                          fontFamily: "Poppins",
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
