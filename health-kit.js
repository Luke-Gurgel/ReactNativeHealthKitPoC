// https://github.com/terrillo/rn-apple-healthkit#wiki
import HealthKit from '@track-info/rn-health-kit';

export const options = {
  permissions: {
    read: [
      'Steps',
      'Weight',
      'StepCount',
      'HeartRate',
      'LeanBodyMass',
      'SleepAnalysis',
      'BodyMassIndex',
      'DistanceCycling',
      'BodyFatPercentage',
      'ActiveEnergyBurned',
      'DistanceWalkingRunning',
    ]
  }
};

const today = new Date().toISOString()
const opt = {
  startDate: new Date(2016,1,1).toISOString(),
  endDate: today
};

export const getHealthData = () => {
  HealthKit.initHealthKit(options, (err) => {
    if (err) return console.log("error initializing HealthKit", err);

    HealthKit.getStepCount({ date: today }, (err, res) => {
      if (err) return console.log('error getting steps for today:', err)
      console.log('steps for today:', res)
    });

    HealthKit.getDailyStepCountSamples({ ...opt }, (err, res) => {
      if (err) return console.log('error getting steps samples:', err)
      console.log('total steps per day over date range:', res)
    });

    HealthKit.getLatestWeight({ unit: 'pound' }, (err, res) => {
      if (err) return console.log('error getting latest weight:', err)
      console.log('latest weight:', res)
    });

    HealthKit.getWeightSamples({ ...opt, unit: 'pound' }, (err, res) => {
      if (err) return console.log('error getting weight samples:', err)
      console.log('weight samples:', res)
    });

    HealthKit.getHeartRateSamples({ ...opt }, (err, res) => {
      if (err) return console.log('error getting heart rate samples:', err)
      console.log('heart rate samples:', res)
    });

    HealthKit.getLatestLeanBodyMass(null, (err, res) => {
      if (err) return console.log('error getting latest lean body mass:', err)
      console.log('latest lean body mass:', res)
    });

    HealthKit.getLeanBodyMassSamples({ ...opt, unit: 'pound' }, (err, res) => {
      if (err) return console.log('error getting lean body mass samples:', err)
      console.log('lean body mass samples:', res)
    });

    HealthKit.getSleepSamples({ ...opt }, (err, res) => {
      if (err) return console.log('error getting sleep samples:', err)
      console.log('sleep samples:', res)
    });

    HealthKit.getLatestBmi(null, (err, res) => {
      if (err) return console.log('error getting bmi sample:', err)
      console.log('bmi sample:', res)
    });

    HealthKit.getLatestBmi(null, (err, res) => {
      if (err) return console.log('error getting bmi sample:', err)
      console.log('bmi sample:', res)
    });

    HealthKit.getDailyDistanceCyclingSamples({ ...opt }, (err, res) => {
      if (err) return console.log('error getting cycling samples:', err)
      console.log('cycling samples:', res)
    });

    HealthKit.getDistanceCycling({ unit: 'mile' }, (err, res) => {
      if (err) return console.log('error getting total distance cycling on a specific day:', err)
      console.log('total distance cycling on a specific day:', res)
    });

    HealthKit.getLatestBodyFatPercentage(null, (err, res) => {
      if (err) return console.log('error getting most recent body fat percentage:', err)
      console.log('most recent body fat percentage:', res)
    });

    HealthKit.getBodyFatPercentageSamples({ ...opt }, (err, res) => {
      if (err) return console.log('error getting body fat percentage samples:', err)
      console.log('body fat percentage samples:', res)
    });

    HealthKit.getActiveEnergyBurned({ ...opt }, (err, res) => {
      if (err) return console.log('error getting a quantity sample type that measures the amount of active energy the user has burned:', err)
      console.log('a quantity sample type that measures the amount of active energy the user has burned:', res)
    });

    HealthKit.getDailyDistanceWalkingRunningSamples({ ...opt }, (err, res) => {
      if (err) return console.log('error getting walking/running samples:', err)
      console.log('walking/running samples:', res)
    });

    HealthKit.getDistanceWalkingRunning({ unit: 'mile' }, (err, res) => {
      if (err) return console.log('error getting total distance walking/running on a specific day:', err)
      console.log('total distance walking/running on a specific day:', res)
    });
  });
}
