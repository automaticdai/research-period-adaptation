float map(float value, float input_min, float input_max, float output_min, float output_max)
{
    if (value >= input_max) {
        return output_max;
    }
    else if (value <= input_min) {
        return output_min;
    }
    else {
        return (value - input_min) / (input_max - input_min) * (output_max - output_min) + output_min;
    }
}

float binary_output(float value, float value_threshold, float output_below, float output_beyond)
{
    if (value >= value_threshold) {
        return output_beyond;
    }
    else {
        return output_below;
    }
}
