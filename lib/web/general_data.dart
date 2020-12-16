import 'package:MyFamilyVoice/web/model/feature_tile_model.dart';
import 'package:flutter/material.dart';

/// All the data

Color headerColor = Colors.black87;

List<FeatureTileModel> getFeaturesTiles1() {
  final List<FeatureTileModel> tileFeatures = <FeatureTileModel>[];
  FeatureTileModel featureTileModel = FeatureTileModel();

  //1
  featureTileModel.setImagePath('GrandadHS.png');
  featureTileModel.setTitle('Record and List to Stories');
  featureTileModel
      .setDescription('Each Story has an image and audio recording. ');
  tileFeatures.add(featureTileModel);

  featureTileModel = FeatureTileModel();

  //2
  featureTileModel.setImagePath('joanAndWade.png');
  featureTileModel.setTitle('Share your stories');
  featureTileModel.setDescription(
      'With Family, Friends, or Global distribution, you decide the audiance.');
  tileFeatures.add(featureTileModel);

  featureTileModel = FeatureTileModel();

  //3
  featureTileModel.setImagePath('Search.png');
  featureTileModel.setTitle('Quickly Find new Friends');
  featureTileModel.setDescription(
      'Instantly search all users of My Family Voice to find Family or Friends');
  tileFeatures.add(featureTileModel);

  featureTileModel = FeatureTileModel();

  return tileFeatures;
}

List<FeatureTileModel> getFeaturesTiles2() {
  final List<FeatureTileModel> tileFeatures = <FeatureTileModel>[];
  FeatureTileModel featureTileModel = FeatureTileModel();

  //4
  featureTileModel.setImagePath('CharlesRacing.png');
  featureTileModel.setTitle('Old or new, everyone has Stories');
  featureTileModel
      .setDescription('Capture memories of times and events that are special');
  tileFeatures.add(featureTileModel);

  featureTileModel = FeatureTileModel();

  //5
  featureTileModel.setImagePath('Profile.png');
  featureTileModel.setTitle('Your Profile');
  featureTileModel.setDescription(
      'You are known by your name and home which is used in Search');
  tileFeatures.add(featureTileModel);

  featureTileModel = FeatureTileModel();

  //6
  featureTileModel.setImagePath('momHS.png');
  featureTileModel.setTitle('Gallery or Camera');
  featureTileModel.setDescription(
      'Select pictures from your device, or use the Camera to take a new picture');
  tileFeatures.add(featureTileModel);

  featureTileModel = FeatureTileModel();

  return tileFeatures;
}
