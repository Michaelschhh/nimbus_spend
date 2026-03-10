import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/colors.dart';

class CurrencyPickerModal extends StatefulWidget {
  final Function(String) onSelect;
  const CurrencyPickerModal({super.key, required this.onSelect});

  @override
  State<CurrencyPickerModal> createState() => _CurrencyPickerModalState();
}

class _CurrencyPickerModalState extends State<CurrencyPickerModal> {
  String query = "";
  final List<String> currencies = ["AED","AFN","ALL","AMD","ANG","AOA","ARS","AUD","AWG","AZN","BAM","BBD","BDT","BGN","BHD","BIF","BMD","BND","BOB","BRL","BSD","BTN","BWP","BYN","BZD","CAD","CDF","CHF","CLP","CNY","COP","CRC","CUC","CUP","CVE","CZK","DJF","DKK","DOP","DZD","EGP","ERN","ETB","EUR","FJD","FKP","GBP","GEL","GHS","GIP","GMD","GNF","GTQ","GYD","HKD","HNL","HRK","HTG","HUF","IDR","ILS","INR","IQD","IRR","ISK","JMD","JOD","JPY","KES","KGS","KHR","KMF","KPW","KRW","KWD","KYD","KZT","LAK","LBP","LKR","LRD","LSL","LYD","MAD","MDL","MGA","MKD","MMK","MNT","MOP","MRU","MUR","MVR","MWK","MXN","MYR","MZN","NAD","NGN","NIO","NOK","NPR","NZD","OMR","PAB","PEN","PGK","PHP","PKR","PLN","PYG","QAR","RON","RSD","RUB","RWF","SAR","SBD","SCR","SDG","SEK","SGD","SHP","SLE","SOS","SRD","SSP","STN","SVC","SYP","SZL","THB","TJS","TMT","TND","TOP","TRY","TTD","TWD","TZS","UAH","UGX","USD","UYU","UZS","VES","VND","VUV","WST","XAF","XCD","XOF","XPF","YER","ZAR","ZMW","ZWL"];

  @override
  Widget build(BuildContext context) {
    final filtered = currencies.where((c) => c.contains(query.toUpperCase())).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text("Select Currency", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => query = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search currency code...",
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(filtered[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () => widget.onSelect(filtered[i]),
                trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textDim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}