/***************************************\
 *                                      *
 *  Drawing on Texture helper functions *
 *      by Dariusz "De JET" Zolna       *
 *     Copyright (c) 2023 Auki Labs     *
 *                                      *
 \**************************************/

RWTexture2D<float> Output;

#define BLACK   0.11
#define RED     0.2
#define GREEN   0.3
#define BLUE    0.4
#define MAGENTA 0.5
#define WHITE   1.0

void draw_line(float2 start, float2 end, const float color)
{
    float2 size;
    Output.GetDimensions(size.x, size.y);

    if(start.x < 0 || end.x < 0 || start.y < 0 || end.y < 0 || start.x >= size.x || end.x >= size.x || start.y >= size.y || end.y >= size.y || distance(start, end) < 2) return;

    float2 pos = start;

    const float dx = floor(abs(pos.x - int(end.x)));
    const float dy = floor(abs(pos.y - int(end.y)));

    const float sx = start.x < end.x ? 1 : -1;
    const float sy = start.y < end.y ? 1 : -1;
    
    float err;
    if (dx > dy) err = floor(dx / 2);
    else err = -floor(dy / 2);

    const float len = max(dx, dy);
    float cnt = 0;
    
    while (cnt++ <= len)
    {
        Output[pos] = color;

        const float e2 = floor(err);
        
        if (e2 > -dx)
        {
            err -= dy;
            pos.x += sx;
            if(pos.x < 0) break;
        }
        
        if (e2 < dy)
        {
            err += dx;
            pos.y += sy;
            if(pos.y < 0) break;
        }
    }
}

void draw_cross(const float2 pos, const float2 size, const float color)
{
    draw_line(pos + float2(-1, 0) * size / 2, pos + float2(1, 0) * size / 2, color);
    draw_line(pos + float2(0, -1) * size / 2, pos + float2(0, 1) * size / 2, color);
}

void draw_outlined_dot(const float2 pos, const float color)
{
    Output[pos + float2(-1, -1)] = BLACK;
    Output[pos + float2( 0, -1)] = BLACK;
    Output[pos + float2( 1, -1)] = BLACK;
    Output[pos + float2(-1,  0)] = BLACK;
    Output[pos + float2( 1,  0)] = BLACK;
    Output[pos + float2(-1,  1)] = BLACK;
    Output[pos + float2( 0,  1)] = BLACK;
    Output[pos + float2( 1,  1)] = BLACK;
    Output[pos] = color;
}

void draw_error(const uint number, const float2 center)
{
    for(uint i=0; i<number; i++)
    {
        draw_outlined_dot(center + float2(5, 0) * (i - number / 2) +  float2(0, 5) * (number - number / 2), RED);
    }
    
}

void draw_rect(const float2 corner1, const float2 corner2, const float2 corner3, const float2 corner4, const float color)
{
    if(corner1.x >= 0 && corner2.x >= 0) draw_line(corner1, corner2, color);
    if(corner2.x >= 0 && corner3.x >= 0) draw_line(corner2, corner3, color);
    if(corner3.x >= 0 && corner4.x >= 0) draw_line(corner3, corner4, color);
    if(corner4.x >= 0 && corner1.x >= 0) draw_line(corner4, corner1, color);
}

void draw_cross_rect(const float2 corner1, const float2 corner2, const float2 corner3, const float2 corner4, const float color)
{
    draw_rect(corner1, corner2, corner3, corner4, color);
    draw_line(corner1, corner3, color);
    draw_line(corner2, corner4, color);
}

void draw_drill5(const float2 pos1, const float2 pos2, const float2 pos3, const float2 pos4)
{
    draw_line(pos1, pos2, RED);
    draw_line(pos2, pos3, GREEN);
    draw_line(pos3, pos4, BLUE);
}