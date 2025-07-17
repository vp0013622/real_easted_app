import 'package:country_state_city/country_state_city.dart';
class CountryStateSelector{

  Future<List<Country>> getCountries() async{
    // Get all countries
    final countries = await getAllCountries();
    return countries;
  }

  Future<Country?> getCountryByCode(String code) async{
    // Get a country
    final country = await getCountryFromCode(code); //'IN
    return country;
  }

  Future<List<State>> getStates() async{
    // Get all states
    final states = await getAllStates();
    return states;
  }

  Future<List<State>> getStatesByCountryCode(Country country) async{
    // Get all states by country iso code
    final states = await getStatesOfCountry(country.isoCode);
    return states;
  }

  Future<List<City>> getCities() async{
    // Get all cities
    final cities = await getAllCities();
    return cities;
  }

  Future<List<City>> getCitiesByCountryCode(Country country) async{
    // Get all states by country iso code
    final cities = await getCountryCities(country.isoCode);
    return cities;
  }

  // // Get all countries
  // final countries = await getAllCountries();
  // // Get all states
  // final states = await getAllStates();
  // // Get all cities
  // final cities = await getAllCities();

  // // Get a country
  // final country = await getCountryFromCode('AF');
  // if (country != null) {
  //   final countryStates = await getStatesOfCountry(country.isoCode);

  //   final countryCitis = await getCountryCities(country.isoCode);
  // }
}