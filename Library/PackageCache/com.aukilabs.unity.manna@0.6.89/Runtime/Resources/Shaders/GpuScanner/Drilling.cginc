/***************************************\
 *                                      *
 *       Edges Drilling functions       *
 *      by Dariusz "De JET" Zolna       *
 *     Copyright (c) 2023 Auki Labs     *
 *                                      *
 \**************************************/

Texture2D Colors;
Texture2D<float> Edges;

float2 TexSize;
SamplerState sampler_colors_linear_clamp;
SamplerState sampler_edges_linear_clamp;

float2 super_drill(const float2 start_pos, const float2 end_pos)
{
    const float2 start_uv = start_pos / TexSize;
    const float2 end_uv = end_pos / TexSize;

    const float step = 1.0 / (distance(start_pos, end_pos) * 50.0);
    
    const float c1 = Colors.SampleLevel(sampler_colors_linear_clamp, start_uv, 0).r;
    const float c2 = Colors.SampleLevel(sampler_colors_linear_clamp, end_uv, 0).r;
    for(float i = 0.0; i < 1.0; i += step)
    {
        const float2 uv = lerp(start_uv, end_uv, i);
        const float c = Colors.SampleLevel(sampler_colors_linear_clamp, uv, 0).r;
        if(abs(c - c2) < abs(c - c1))
        {
            return uv * TexSize;
        }
    }
    return float2(-1, -1);
}

float2 super_drill(const float2 start_pos, const float2 end_pos, const float gray1, const float gray2)
{
    const float2 start_uv = start_pos / TexSize;
    const float2 end_uv = end_pos / TexSize;

    const float step = 1.0 / (distance(start_pos, end_pos) * 50.0);
    
    for(float i = 0.0; i < 1.0; i += step)
    {
        const float2 uv = lerp(start_uv, end_uv, i);
        const float c = Colors.SampleLevel(sampler_colors_linear_clamp, uv, 0).r;
        if(abs(c - gray2) < abs(c - gray1))
        {
            return uv * TexSize;
        }
    }
    return float2(-1, -1);
}

float2 super_drill(const float2 start_pos, const float2 step, const float max_distance)
{
    float2 distance = float2(0, 0);
    while(length(distance) < max_distance)
    {
        if(Edges[start_pos + distance] >= 0.5) break;
        distance += step;
    }
    if(length(distance) >= max_distance) return float2(-1, -1);

    const float c1 = Colors[start_pos + distance - step].r;
    const float c2 = Colors[start_pos + distance].r;
    
    const float2 start_uv = (start_pos + distance - step) / TexSize;
    const float2 end_uv = (start_pos + distance) / TexSize;

    for(float i = 0.0; i < 1.0; i += 0.01)
    {
        const float2 uv = lerp(start_uv, end_uv, i);
        const float c = Colors.SampleLevel(sampler_colors_linear_clamp, uv, 0).r;
        if(abs(c - c2) < abs(c - c1))
        {
            return uv * TexSize;
        }
    }
    return float2(-1, -1);
}


float2 drill_right(const float2 start_pos)
{
    float2 pos = start_pos;
    for(float cnt = 0; cnt < 200; cnt++)
    {
        if(Edges[pos] >= 0.5) return pos;
        pos.x ++;
    }
    return float2(-1, -1);
}

/*
int2 fast_drill(const int2 start_pos, const int2 step)
{
    int2 pos = start_pos;
    int dist = 0;
    while(dist < 200)
    {
        const float2 uv = (float2)pos / TexSize;
        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 5) > 0.01)
        {
            if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 4) > 0.01)
            {
                if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 3) > 0.01)
                {
                    if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 2) > 0.01)
                    {
                        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 1) > 0.01)
                        {
                            if(Edges[uv * TexSize].r < 0.5)
                            {
                                pos += step;
                                dist ++;
                            }
                            else
                            {
                                if(dist > 0) return pos;
                                break;
                            }
                        }
                        else
                        {
                            const int2 new_pos = (pos + step * 2) & int2(0xffffffff ^ 1, 0xffffffff ^ 1);
                            dist += distance(pos, new_pos);
                            pos = new_pos;
                        }
                    }
                    else
                    {
                        const int2 new_pos = (pos + step * 4) & int2(0xffffffff ^ 3, 0xffffffff ^ 3);
                        dist += distance(pos, new_pos);
                        pos = new_pos;
                    }
                }
                else
                {
                    const int2 new_pos = (pos + step * 8) & int2(0xffffffff ^ 7, 0xffffffff ^ 7);
                    dist += distance(pos, new_pos);
                    pos = new_pos;
                }
            }
            else
            {
                const int2 new_pos = (pos + step * 16) & int2(0xffffffff ^ 15, 0xffffffff ^ 15);
                dist += distance(pos, new_pos);
                pos = new_pos;
            }
        }
        else
        {
            const int2 new_pos = (pos + step * 32) & int2(0xffffffff ^ 31, 0xffffffff ^ 31);
            dist += distance(pos, new_pos);
            pos = new_pos;
        }
    }
    return int2(-1, -1);
}
*/

int2 fast_drill(const int2 start_pos, const int2 step)
{
    int2 pos = start_pos;
    int dist = 0;
    while(dist < 200)
    {
        if(Edges[pos].r < 0.5)
        {
            pos += step;
            dist ++;
        }
        else
        {
            if(dist > 0) return pos;
            break;
        }
    }
    return int2(-1, -1);
}

/*
int2 fast_drill_right(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.x + 60, 0, TexSize.x - 1); 
    while(pos.x < max_pos)
    {
        const float2 uv = (float2)pos / TexSize;
        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 5) > 0.01)
        {
            if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 4) > 0.01)
            {
                if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 3) > 0.01)
                {
                    if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 2) > 0.01)
                    {
                        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 1) > 0.01)
                        {
                            if(Edges[uv * TexSize].r < 0.5)
                            {
                                pos.x ++;
                            }
                            else
                            {
                                if(pos.x > start_pos.x) return pos;
                                break;
                            }
                        }
                        else
                        {
                            pos.x = (pos.x & (0xffffffff ^ 1)) + 2; 
                        }
                    }
                    else
                    {
                        pos.x = (pos.x & (0xffffffff ^ 3)) + 4;
                    }
                }
                else
                {
                    pos.x = (pos.x & (0xffffffff ^ 7)) + 8;
                }
            }
            else
            {
                pos.x = (pos.x & (0xffffffff ^ 15)) + 16;
            }
        }
        else
        {
            pos.x = (pos.x & (0xffffffff ^ 31)) + 32;
        }
    }
    return int2(-1, -1);
}
*/

int2 fast_drill_right(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.x + 60, 0, TexSize.x - 1); 
    while(pos.x < max_pos)
    {
        if(Edges[pos].r < 0.5)
        {
            pos.x ++;
        }
        else
        {
            if(pos.x > start_pos.x) return pos;
            break;
        }
    }
    return int2(-1, -1);
}

/*
int2 fast_drill_up(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.y + 110, 0, TexSize.y - 1); 
    while(pos.y < max_pos)
    {
        const float2 uv = (float2)pos / TexSize;
        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 5) > 0.01)
        {
            if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 4) > 0.01)
            {
                if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 3) > 0.01)
                {
                    if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 2) > 0.01)
                    {
                        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 1) > 0.01)
                        {
                            if(Edges[uv * TexSize].r < 0.5)
                            {
                                pos.y ++;
                            }
                            else
                            {
                                return pos;
                            }
                        }
                        else
                        {
                            pos.y = (pos.y & (0xffffffff ^ 1)) + 2; 
                        }
                    }
                    else
                    {
                        pos.y = (pos.y & (0xffffffff ^ 3)) + 4; 
                    }
                }
                else
                {
                    pos.y = (pos.y & (0xffffffff ^ 7)) + 8;
                }
            }
            else
            {
                pos.y = (pos.y & (0xffffffff ^ 15)) + 16;
            }
        }
        else
        {
            pos.y = (pos.y & (0xffffffff ^ 31)) + 32;
        }
    }
    return int2(-1, -1);
}
*/

int2 fast_drill_up(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.y + 110, 0, TexSize.y - 1); 
    while(pos.y < max_pos)
    {
        if(Edges[pos].r < 0.5)
        {
            pos.y ++;
        }
        else
        {
            return pos;
        }
    }
    return int2(-1, -1);
}

/*
int2 fast_drill_down(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.y - 60, 0, TexSize.y - 1); 
    while(pos.y > max_pos)
    {
        const float2 uv = (float2)pos / TexSize;
        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 5) > 0.01)
        {
            if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 4) > 0.01)
            {
                if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 3) > 0.01)
                {
                    if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 2) > 0.01)
                    {
                        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 1) > 0.01)
                        {
                            if(Edges[uv * TexSize].r < 0.5)
                            {
                                pos.y --;
                            }
                            else
                            {
                                return pos;
                            }
                        }
                        else
                        {
                            pos.y = (pos.y & (0xffffffff ^ 1)) - 1; 
                        }
                    }
                    else
                    {
                        pos.y = (pos.y & (0xffffffff ^ 3)) - 1;
                    }
                }
                else
                {
                    pos.y = (pos.y & (0xffffffff ^ 7)) - 1;
                }
            }
            else
            {
                pos.y = (pos.y & (0xffffffff ^ 15)) - 1;
            }
        }
        else
        {
            pos.y = (pos.y & (0xffffffff ^ 31)) - 1;
        }
    }
    return int2(-1, -1);
}
*/

int2 fast_drill_down(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.y - 60, 0, TexSize.y - 1); 
    while(pos.y > max_pos)
    {
        if(Edges[pos].r < 0.5)
        {
            pos.y --;
        }
        else
        {
            return pos;
        }
    }
    return int2(-1, -1);
}

/*
int2 fast_drill_left(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.x - 60, 0, TexSize.x - 1); 
    while(pos.x > max_pos)
    {
        const float2 uv = (float2)pos / TexSize;
        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 5) > 0.01)
        {
            if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 4) > 0.01)
            {
                if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 3) > 0.01)
                {
                    if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 2) > 0.01)
                    {
                        if(Edges.SampleLevel(sampler_edges_linear_clamp, uv, 1) > 0.01)
                        {
                            if(Edges[uv * TexSize].r < 0.5)
                            {
                                pos.x --;
                            }
                            else
                            {
                                return pos;
                            }
                        }
                        else
                        {
                            pos.x = (pos.x & (0xffffffff ^ 1)) - 1; 
                        }
                    }
                    else
                    {
                        pos.x = (pos.x& (0xffffffff ^ 3)) - 1;
                    }
                }
                else
                {
                    pos.x = (pos.x & (0xffffffff ^ 7)) - 1;
                }
            }
            else
            {
                pos.x = (pos.x & (0xffffffff ^ 15)) - 1;
            }
        }
        else
        {
            pos.x = (pos.x & (0xffffffff ^ 31)) - 1;
        }
    }
    return int2(-1, -1);
}
*/

int2 fast_drill_left(const int2 start_pos)
{
    int2 pos = start_pos;
    const int max_pos = clamp(start_pos.x - 60, 0, TexSize.x - 1); 
    while(pos.x > max_pos)
    {
        if(Edges[pos].r < 0.5)
        {
            pos.x --;
        }
        else
        {
            return pos;
        }
    }
    return int2(-1, -1);
}


float drill(const float2 start_pos, const float2 step, const float max_distance)
{
    float2 distance = 0;
    while(length(distance) < max_distance)
    {
        if(Edges[start_pos.xy + distance] >= 0.5) return length(distance);
        distance += step;
    }
    return -1;
}



float2 color_drill(const int2 start_pos, const int2 step, const int start_distance, const int edges_count)
{
    if(start_distance > 150) return float2(-1, -1);

    float start_color = Colors[start_pos].r;
    int distance = start_distance;
    int edge_num = 0;
    while(distance < 450)
    {
        while(abs(Colors[start_pos + step * distance].r - start_color) < 0.1)
        {
            distance ++;
            if (distance >= 450) return float2(-1, -1);
        }
        start_color = Colors[start_pos + step * distance].r;
        
        edge_num++;
        if (edge_num >= edges_count) return floor(start_pos + step * distance) + float2(0.5, 0.5);

        while(abs(Colors[start_pos + step * distance].r - start_color) < 0.1)
        {
            distance ++;
            if (distance >= 450) break;
        }
        start_color = Colors[start_pos + step * distance].r;
    }
    return float2(-1, -1);
}


float2 drill(const int2 start_pos, const int2 step, const int start_distance, const int edges_count)
{
    if(start_distance > 150) return float2(-1, -1);
    
    int distance = start_distance;
    int edge_num = 0;
    while(distance < 450)
    {
        while(Edges[start_pos + step * distance] < 0.5)
        {
            distance ++;
            if (distance >= 450) return float2(-1, -1);
        }
        
        edge_num++;
        if (edge_num >= edges_count) return floor(start_pos + step * distance) + float2(0.5, 0.5);
        
        while(Edges[start_pos + step * distance] >= 0.5)
        {
            distance ++;
            if (distance >= 450) break;
        }
    }
    return float2(-1, -1);
}


int color_drill(const int2 start_pos, const int2 step, const int start_distance, const int max_distance, const int edges_count)
{
    if(start_distance >= max_distance) return -1;
    
    float start_color = Colors[start_pos].r;
    int distance = start_distance;
    int edge_num = 0;
    while(distance < max_distance)
    {
        while(abs(Colors[start_pos + step * distance].r - start_color) < 0.1)
        {
            distance ++;
            if (distance >= max_distance) return -1;
        }
        start_color = Colors[start_pos + step * distance].r;
        Output[start_pos + step * distance] = BLUE;
        
        edge_num++;
        if (edge_num >= edges_count) return distance;
    }
    return -1;
}

static bool compare_gray(const float gray, const float gray1, const float gray2)
{
    return abs(gray - gray1) < abs(gray - gray2);
}


int2 color_drill(const int2 start_pos, const int2 step, const int start_distance, const int max_distance, const int edges_count, float gray1, float gray2)
{
    if(start_distance >= max_distance) return -1;

    int distance = start_distance;
    int edge_num = 0;
    while(distance < max_distance)
    {
        while(compare_gray(Colors[start_pos + step * distance].r, gray1, gray2))
        {
            distance ++;
            if (distance >= max_distance) return float2(-1, -1);
        }
        const float g = gray1;
        gray1 = gray2;
        gray2 = g;
        
        edge_num++;
        if (edge_num >= edges_count) return start_pos + step * distance;
    }
    return float2(-1, -1);
}


float2 color_drill(const float2 start_pos, const float2 end_pos)
{
    if(distance(start_pos, end_pos) < 2) return -1;

    const float gray1 = Colors[start_pos].r;
    const float gray2 = Colors[end_pos].r;
    const float step = 1.0 / distance(start_pos, end_pos);
    for(float i = 0; i < 1.0; i += step)
    {
        const float2 pos = lerp(start_pos, end_pos, i);
        if(compare_gray(Colors[pos].r, gray1, gray2) > 0)
        {
            return pos;
        }
    }
    return float2(-1, -1);
}

struct drill3
{
    bool valid;
    float2 edges[3];
};

drill3 color_drill_3(const float2 start_pos, const float2 step, const float gray1, const float gray2)
{
    drill3 result;
    result.valid = false;
    result.edges[0] = start_pos;
    result.edges[1] = start_pos;
    result.edges[2] = start_pos;

    float max_distance = 70;
    float2 pos = start_pos;
    
    while(compare_gray(Colors[pos].r, gray1, gray2))
    {
        if (distance(start_pos, pos) > max_distance)
        {
            return result;
        }
        pos += step;
    }

    pos = super_drill(pos - step, pos);
    
    result.edges[0] = pos;
    const float cell_size = distance(start_pos, pos) * 0.7;
    
    max_distance = cell_size * 3;
    pos += step;
    
    while(compare_gray(Colors[pos].r, gray2, gray1))
    {
        if (distance(start_pos, pos) > max_distance)
        {
            return result;
        }
        pos += step;
    }

    pos = super_drill(pos - step, pos);

    if(abs(1 - cell_size / distance(result.edges[0], pos)) > 1)
    {
        return result;
    }
    
    result.edges[1] = pos;
    max_distance += cell_size * 1.5;
    pos += step;

    while(compare_gray(Colors[pos].r, gray1, gray2))
    {
        if (distance(start_pos, pos) > max_distance)
        {
            return result;
        }
        pos += step;
    }

    pos = super_drill(pos - step, pos);
    
    if(abs(1 - cell_size / distance(result.edges[1], pos)) > 1)
    {
        return result;
    }
    
    result.edges[2] = pos;
    
    result.valid = true;
    return result;
}


struct timing_pattern
{
    int count;
    float2 edges[64];
};

timing_pattern drill_timing(const float2 start_pos, const float2 end_pos, const float gray1, const float gray2)
{
    timing_pattern timing;
    timing.count = 0;
    for(int i=0; i<64; i++)
    {
        timing.edges[i] = float2(-1, -1);
    }
    
    if(distance(start_pos, end_pos) < 2) return timing;

    const float2 start_uv = start_pos / TexSize;
    const float2 end_uv = end_pos / TexSize;

    float2 edges[64];
    const float step = 1.0 / distance(start_pos, end_pos);
    bool c = compare_gray(Colors[start_pos].r, gray1, gray2);
    int cnt = 0;
    for(float n = 0; n < 1.0; n += step)
    {
        const float2 uv = lerp(start_uv, end_uv, n);
        const float gray = Colors.SampleLevel(sampler_colors_linear_clamp, uv, 0).r;
        if(compare_gray(gray, gray1, gray2) != c)
        {
            edges[cnt] = uv * TexSize;
            
            if(cnt > 2)
            {
                const float dist1 = distance(edges[cnt-2], edges[cnt-1]);
                if(dist1 > 100) return timing;
                const float dist2 = distance(edges[cnt-1], edges[cnt]);
                if(dist2 > 100) return timing;
                if(abs(1 - dist1 / dist2) > 1) return timing;
            }
            
            c = !c;
            cnt ++;
            if(cnt > 50) return timing; 
        }
    }

    for(int j=0; j<cnt; j++)
    {
        timing.edges[j] = edges[j];
    }
    
    timing.count = cnt;
    return timing;
}

int drill_timing_debug(const float2 start_pos, const float2 end_pos, const float gray1, const float gray2)
{
    if(distance(start_pos, end_pos) < 2) return 0;

    float2 edges[3];
    int edge_index = 0;
    
    const float2 start_uv = start_pos / TexSize;
    const float2 end_uv = end_pos / TexSize;
    
    const float step = 1.0 / distance(start_pos, end_pos);
    bool c = compare_gray(Colors[start_pos].r, gray1, gray2);
    int cnt = 0;
    for(float i = 0; i < 1.0; i += step)
    {
        const float2 uv = lerp(start_uv, end_uv, i);
        const float gray = Colors.SampleLevel(sampler_colors_linear_clamp, uv, 0).r;
        if(compare_gray(gray, gray1, gray2) != c)
        {
            if(cnt > 1)
            {
                edges[edge_index] = uv * TexSize;
                if(edge_index == 2)
                {
                    const float dist1 = distance(edges[0], edges[1]);
                    const float dist2 = distance(edges[1], edges[2]);
                    if(abs(1 - dist1 / dist2) > 1.0)
                    {
                        return 0;
                    }
                    edges[0] = edges[1];
                    edges[1] = edges[2];
                }
                else
                {
                    edge_index ++;
                }
            }
            Output[uv * TexSize] = GREEN;
            c = !c;
            cnt ++;
            if(cnt > 63) return 0; 
        }
    }
    return cnt;
}


drill3 color_drill_3(const float2 start_pos, const float2 step)
{
    drill3 result;
    result.valid = false;
    result.edges[0] = start_pos;
    result.edges[1] = start_pos;
    result.edges[2] = start_pos;

    float2 pos = start_pos;
    while(Edges[pos].r < 0.5)
    {
        if (distance(start_pos, pos) > 110)
        {
            return result;
        }
        pos += step;
    }
    const float cell_size = (distance(start_pos, pos) * 0.66666);

    pos = super_drill(start_pos + step * cell_size, start_pos + step * cell_size * 2);
    if(pos.x < 0) return result;
    result.edges[0] = pos;
    const float dist1 = distance(start_pos, result.edges[0]) * 0.6666;
    if(dist1 < 1) return result;
    
    pos = super_drill(start_pos + step * cell_size * 2, start_pos + step * cell_size * 3);
    if(pos.x < 0) return result;
    result.edges[1] = pos;
    const float dist2 = distance(result.edges[0], result.edges[1]);
    if(dist2 < 1) return result;
    
    pos = super_drill(start_pos + step * cell_size * 3, start_pos + step * cell_size * 4);
    if(pos.x < 0) return result;
    result.edges[2] = pos;

    const float dist3 = distance(result.edges[1], result.edges[2]);
    if(dist3 < 1) return result;
    
    result.valid = true;
    return result;
}



int drill(const int2 start_pos, const int2 step, const int start_distance, const int max_distance, const int edges_count)
{
    if(start_distance >= max_distance) return -1;
    
    int distance = start_distance;
    int edge_num = 0;
    while(distance < max_distance)
    {
        while(Edges[start_pos.xy + step * distance] < 0.5)
        {
            distance ++;
            if (distance >= max_distance) return -1;
        }
        
        edge_num++;
        if (edge_num >= edges_count) return distance;
        
        while(Edges[start_pos.xy + step * distance] >= 0.5)
        {
            distance ++;
            if (distance >= max_distance) break;
        }
    }
    return -1;
}

float2 drill_line(int2 start, int2 end)
{
    if(start.x < 0 || end.x < 0 || distance(start, end) < 1) return float2(-1, -1);
    
    float2 pos = start;

    const float dx = floor(abs(pos.x - end.x));
    const float dy = floor(abs(pos.y - end.y));

    const float sx = start.x < end.x ? 1 : -1;
    const float sy = start.y < end.y ? 1 : -1;
    
    float err;
    if (dx > dy) err = floor(dx / 2);
    else err = -floor(dy / 2);

    const float len = max(dx, dy);
    float cnt = 0;
    
    while (cnt++ < len)
    {
        if(Edges[pos] > 0.5) return floor(pos) + float2(0.5, 0.5);;

        const float e2 = floor(err);
        
        if (e2 > -dx)
        {
            err -= dy;
            pos.x += sx;
        }
        
        if (e2 < dy)
        {
            err += dx;
            pos.y += sy;
        }
    }
    return float2(-1, -1);
}

float2 drill_along_line(int2 start, int2 end, const int edges_count)
{
    if(start.x < 0 || distance(start, end) < 1) return float2(-1, -1);

    float2 pos = start;

    const float dx = floor(abs(pos.x - end.x));
    const float dy = floor(abs(pos.y - end.y));

    const float sx = start.x < end.x ? 1 : -1;
    const float sy = start.y < end.y ? 1 : -1;
    
    float err;
    if (dx > dy) err = floor(dx / 2);
    else err = -floor(dy / 2);

    const float len = max(dx, dy);
    float cnt = 0;

    int edges = 0;
    bool black = (Edges[pos] < 0.5);

    while (cnt++ < len)
    {
        const bool c = Edges[pos] > 0.5;
        if(black)
        {
            if(c)
            {
                edges++;
                if(edges >= edges_count)
                {
                    return floor(pos) + float2(0.5, 0.5);;
                }
                black = false;
            }
        }
        else if(!c)
        {
            black = true;
        }

        const float e2 = floor(err);
        
        if (e2 > -dx)
        {
            err -= dy;
            pos.x += sx;
        }
        
        if (e2 < dy)
        {
            err += dx;
            pos.y += sy;
        }
    }
    return float2(-1, -1);
}

static uint count_edges_along_line(int2 start, int2 end)
{
    if(start.x < 0 || end.x < 0 || distance(start, end) < 1) return 0;

    float2 pos = start;

    const float dx = floor(abs(pos.x - end.x));
    const float dy = floor(abs(pos.y - end.y));

    const float sx = start.x < end.x ? 1 : -1;
    const float sy = start.y < end.y ? 1 : -1;
    
    float err;
    if (dx > dy) err = floor(dx / 2);
    else err = -floor(dy / 2);

    const float len = max(dx, dy);
    float cnt = 0;

    int edges = 0;
    bool black = (Edges[pos] < 0.5);

    while (cnt++ < len)
    {
        const bool c = Edges[pos] > 0.5;
        if(black & c)
        {
            edges++;
            black = false;
        }
        else if(!c)
        {
            black = true;
        }

        const int e2 = floor(err);
        
        if (e2 > -dx)
        {
            err -= dy;
            pos.x += sx;
        }
        
        if (e2 < dy)
        {
            err += dx;
            pos.y += sy;
        }
    }
    return edges;
}

static float2 get_middle_point_between_edges(const int2 start_pos, const int2 end_pos, const int max_edges)
{
    const float2 edge_far = drill_along_line(start_pos, end_pos, max_edges); 
    const float2 edge_near = drill_along_line(start_pos, end_pos, max_edges - 1);
    if(edge_near.x < 0 || edge_far.x < 0) return float2(-1, -1);
    return lerp(edge_near, edge_far, 0.5);
}

float2 get_intersection_point(const float2 p1_a, const float2 p1_b, const float2 p2_a, const float2 p2_b)
{
    float2 d1 = (p1_b-p1_a); //Direction Line 1
    const float2 d2 = (p2_b-p2_a); //Direction Line 2
    const float2 d1_n = float2(d1.y, -d1.x); //orthogonal line to d1 (normal), optimal direction to reach d1 from anywhere
    const float dist = dot(p1_a-p2_a,d1_n);//projection on the optimal direction = distance
    const float rate = dot(d2,d1_n); //rate : how much is our d2 line in the optimal direction? (<=1.0)
    float t = 10000000.0 ; //INFINITY! (rare parallel case)
    if(rate != 0.0) t = dist/rate; //Starting from p2a, find the distance to reach the other line along d2.
    return p2_a+t*d2;  //start point + distance along d2 * d2 direction = intersection.
}

static bool check_intersection_point(const float2 a1, const float2 a2, const float2 b1, const float2 b2)
{
    const float2 s1 = a2 - a1;
    const float2 s2 = b2 - b1;
    const float n = abs(s1.x * s2.y - s2.x * s1.y);
    return (n < 0.00001);
}

