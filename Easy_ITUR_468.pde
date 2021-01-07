

void setup()
{
  /*
    Uses the number of desired spectrum bands and sample rate to determine the ITU-R 468 noise weighting
    curve. This function generates an array the length of the number of desired spectrum bands with
    a percentage value that can be applied to an FFT of the same number of bands.
  */
  calc_ITUR468(spectrum_bands, SAMPLE_RATE);
  exit();
}

//Audio-related Definitions
public double R_itu_1 = 1.246332637532143 * pow(10,-4);

public double R_itu_h1_1 = -4.737338081378384 *pow(10,-24);
public double R_itu_h1_2 = 2.043828333606125 * pow(10,-15);
public double R_itu_h1_3 = -1.363894795463638 * pow(10,-7);

public double R_itu_h2_1 = 1.306612257412824 * pow(10,-19);
public double R_itu_h2_2 = -2.118150887518656 * pow(10,-11);
public double R_itu_h2_3 = 5.559488023498642 * pow(10,-4);

public int SAMPLE_RATE = 96000;
public int HEARING_LIMIT_FREQ = 20000;
public int spectrum_bands = 512;

public float[] freq_boundaries = new float[spectrum_bands];
public double[] ITUR468_amp_modifier = new double[spectrum_bands];

public void calc_ITUR468(int num_bands, int sample_rate)
{
  float avail_frequency = sample_rate/2;
  float frequency_per_band = avail_frequency/num_bands;
  double[] ITUR468_db_delta = new double[num_bands];
  double h1;
  double h2;
  double R_itu;
  double itu;
  double min_itu = 0;
  double max_itu = 0;
  
  //Calculate ITU for every available frequency of the spectrum
  for (int i = 0; i < num_bands; i++)
  {
    freq_boundaries[i] = (i * frequency_per_band) + frequency_per_band;

    h1 = get_ITUR468_h1(freq_boundaries[i]);
    h2 = get_ITUR468_h2(freq_boundaries[i]);
    //System.out.print(h1 + "\n");
    //System.out.print(h2 + "\n");
    R_itu = (R_itu_1 * freq_boundaries[i]) / sqrt(pow((float)h1,2)+pow((float)h2,2));
    //System.out.print(freq_boundaries[i] + " :R_itu: " + R_itu + "\n");
    itu = 18.2 + (20*(log((float)R_itu)/log(10)));
    
    //System.out.print(freq_boundaries[i] + " :itu: " + itu + "\n");
        
    if(itu > max_itu && freq_boundaries[i] < HEARING_LIMIT_FREQ)
      max_itu = itu;
    if(itu < min_itu && freq_boundaries[i] < HEARING_LIMIT_FREQ)
      min_itu = itu;
      
    ITUR468_db_delta[i] = itu;
  }
  
  //System.out.print("Min ITU: " + min_itu + "\n");
  //System.out.print("Max ITU: " + max_itu + "\n");
  
  for(int i = 0; i < num_bands; i++)
  {
    //System.out.print(freq_boundaries[i] + " db delta " + ITUR468_db_delta[i] + "\n");
    if (freq_boundaries[i] > HEARING_LIMIT_FREQ)
      ITUR468_amp_modifier[i] = 0;
    else
      ITUR468_amp_modifier[i] = (ITUR468_db_delta[i] + abs((float)min_itu))/(max_itu+abs((float)min_itu));
    //System.out.print(freq_boundaries[i] + " :mod: " + ITUR468_amp_modifier[i] + "\n");
  }
}

public double get_ITUR468_h1(float freq)
{
  return (R_itu_h1_1*pow(freq,6)) + (R_itu_h1_2*pow(freq,4)) + (R_itu_h1_3*pow(freq,2)) + 1;
}
public double get_ITUR468_h2(float freq)
{
  return (R_itu_h2_1*pow(freq,5)) + (R_itu_h2_2*pow(freq,3)) + (R_itu_h2_3*freq);
}
