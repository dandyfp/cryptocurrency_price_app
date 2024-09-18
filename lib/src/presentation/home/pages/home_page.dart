import 'dart:convert';

import 'package:cryptocurrency_price_app/src/presentation/misc/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../bloc/websocket_bloc.dart';
import '../bloc/websocket_event.dart';
import '../bloc/websocket_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TradingData> chartData = [];
  Map<String, SymbolData> watchlistData = {};
  late TooltipBehavior tooltipBehavior;

  @override
  void initState() {
    tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebSocket Crypto Data"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: BlocBuilder<WebSocketBloc, WebSocketState>(
              builder: (context, state) {
                if (state is WebSocketInitial) {
                  return const Center(
                    child: Text('Connectting'),
                  );
                } else if (state is WebSocketConnected) {
                  return const Center(child: Text("Connected"));
                } else if (state is WebSocketDisconnected) {
                  return const Center(child: Text("Disconnected"));
                } else if (state is WebSocketMessageReceivedState) {
                  final message = state.message;
                  final double price =
                      double.tryParse(_extractPrice(message)) ?? 0;
                  final DateTime time = _extractTime(message);
                  chartData.add(TradingData(time, price));
                  if (chartData.length > 1) {
                    watchlistData = _parseWatchlist(message);
                  }
                  return SfCartesianChart(
                    tooltipBehavior: tooltipBehavior,
                    margin: const EdgeInsets.only(
                      bottom: 8.0,
                      left: 0,
                      right: 0,
                      top: 0,
                    ),
                    plotAreaBorderWidth: 0,
                    primaryXAxis: const DateTimeAxis(
                      intervalType: DateTimeIntervalType.seconds,
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      majorGridLines: MajorGridLines(width: 0),
                      minorGridLines: MinorGridLines(width: 0),
                      axisLine: AxisLine(width: 0, color: Colors.transparent),
                    ),
                    primaryYAxis: const NumericAxis(
                      labelPosition: ChartDataLabelPosition.outside,
                      labelAlignment: LabelAlignment.end,
                      edgeLabelPlacement: EdgeLabelPlacement.none,
                      labelStyle: TextStyle(fontSize: 8),
                      majorGridLines: MajorGridLines(width: 0),
                      tickPosition: TickPosition.outside,
                      minorGridLines: MinorGridLines(width: 0),
                      axisLine: AxisLine(width: 0, color: Colors.transparent),
                      majorTickLines:
                          MajorTickLines(size: 10, color: Colors.transparent),
                      rangePadding: ChartRangePadding.normal,
                      maximum: 80000,
                    ),
                    series: <CartesianSeries>[
                      SplineAreaSeries<TradingData, DateTime>(
                        dataSource: chartData,
                        xValueMapper: (TradingData data, _) => data.time,
                        yValueMapper: (TradingData data, _) => data.price,
                        color: Colors.lightBlueAccent.withOpacity(0.5),
                        borderColor: Colors.blue,
                        borderWidth: 2,
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightBlueAccent.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.bottom,
                          textStyle: const TextStyle(color: Colors.black),
                          builder: (dynamic data, dynamic point, dynamic series,
                              int pointIndex, int seriesIndex) {
                            return Text(
                              '${data.time.hour}:${data.time.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 6),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text("Unknown state"));
              },
            ),
          ),
          BlocBuilder<WebSocketBloc, WebSocketState>(
            builder: (context, state) {
              if (state is WebSocketMessageReceivedState) {
                final btcData =
                    watchlistData['BTC-USD'] ?? SymbolData('BTC-USD', 0, 0, 0);
                final ethData =
                    watchlistData['ETH-USD'] ?? SymbolData('ETH-USD', 0, 0, 0);
                return Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.width * 0.92,
                  decoration: BoxDecoration(
                    color: AppColors.contentColorBlack.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 10, 0, 0),
                        child: Text(
                          "Watchlist",
                          style: TextStyle(
                              color: AppColors.contentColorWhite, fontSize: 16),
                        ),
                      ),
                      const Divider(thickness: 0.5),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Symbol",
                                style: TextStyle(
                                    color: AppColors.contentColorWhite,
                                    fontSize: 12)),
                            Text("Last",
                                style: TextStyle(
                                    color: AppColors.contentColorWhite,
                                    fontSize: 12)),
                            Text("Chg",
                                style: TextStyle(
                                    color: AppColors.contentColorWhite,
                                    fontSize: 12)),
                            Text("Chg%",
                                style: TextStyle(
                                    color: AppColors.contentColorWhite,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      const Divider(thickness: 0.5),
                      _buildWatchlistRow(btcData),
                      _buildWatchlistRow(ethData),
                    ],
                  ),
                );
              }
              return const Center(child: SizedBox());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<WebSocketBloc>(context).add(ConnectToWebSocket());
        },
        child: const Icon(Icons.close),
      ),
    );
  }

  Map<String, SymbolData> _parseWatchlist(String message) {
    final dynamic decoded = jsonDecode(message);
    if (decoded is Map<String, dynamic>) {
      final symbol = decoded['s'] as String;
      final lastPrice = double.tryParse(decoded['p'].toString()) ?? 0;
      final change = double.tryParse(decoded['dc'].toString()) ?? 0;
      final changePercent = double.tryParse(decoded['dd'].toString()) ?? 0;
      watchlistData[symbol] =
          SymbolData(symbol, lastPrice, change, changePercent);
    }
    return watchlistData;
  }

  String _extractPrice(String message) {
    final RegExp regExp = RegExp(r'"p":"([\d.]+)"');
    final match = regExp.firstMatch(message);
    return match != null ? match.group(1)! : "0";
  }

  DateTime _extractTime(String message) {
    final RegExp regExp = RegExp(r'"t":(\d+)');
    final match = regExp.firstMatch(message);
    if (match != null) {
      final timestamp = int.tryParse(match.group(1)!) ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return DateTime.now();
    }
  }

  Widget _buildWatchlistRow(SymbolData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data.symbol,
              style: const TextStyle(
                  color: AppColors.contentColorWhite, fontSize: 12)),
          Text(data.lastPrice.toString(),
              style: const TextStyle(
                  color: AppColors.contentColorWhite, fontSize: 12)),
          Text(data.change.toString(),
              style: const TextStyle(
                  color: AppColors.contentColorWhite, fontSize: 12)),
          Text('${data.changePercent.toStringAsFixed(2)}%',
              style: const TextStyle(
                  color: AppColors.contentColorWhite, fontSize: 12)),
        ],
      ),
    );
  }
}

class TradingData {
  TradingData(this.time, this.price);
  final DateTime time;
  final double price;
}

class SymbolData {
  SymbolData(this.symbol, this.lastPrice, this.change, this.changePercent);
  final String symbol;
  final double lastPrice;
  final double change;
  final double changePercent;
}
