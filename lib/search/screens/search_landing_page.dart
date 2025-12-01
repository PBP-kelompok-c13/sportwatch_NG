import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sportwatch_ng/config.dart';
import 'package:sportwatch_ng/search/models/search_models.dart';
import 'package:sportwatch_ng/search/widgets/featured_products_section.dart';
import 'package:sportwatch_ng/search/widgets/header_card.dart';
import 'package:sportwatch_ng/search/widgets/search_filters_card.dart';
import 'package:sportwatch_ng/search/widgets/search_results_card.dart';
import 'package:sportwatch_ng/search/widgets/search_side_panels.dart';
import 'package:sportwatch_ng/search/widgets/search_summary_card.dart';
import 'package:sportwatch_ng/widgets/theme_toggle_button.dart';

part 'search_landing_page_state.dart';
part 'search_page_snapshot.dart';
part 'search_preset_sheet.dart';

class SearchLandingPage extends StatefulWidget {
  const SearchLandingPage({super.key});

  @override
  State<SearchLandingPage> createState() => _SearchLandingPageState();
}
