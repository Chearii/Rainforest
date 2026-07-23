realfps_sum += fps_real;

tick++;

if ((tick & 15) == 0)
{
	realfps_avg = realfps_sum / 16;
	realfps_sum = 0;
	tick = 0;
}