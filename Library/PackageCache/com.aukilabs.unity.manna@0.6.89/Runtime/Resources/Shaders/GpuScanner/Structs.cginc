struct finder
{
    uint count;
    uint cluster;
    float2 center;
/*
    float area;
    float2 tl;
    float2 tr;
    float2 rt;
    float2 rb;
    float2 br;
    float2 bl;
    float2 lb;
    float2 lt;
    float2 c1;
    float2 c2;
    float2 c3;
    float2 c4;
    bool corners_ready;
*/
};

struct marker
{
    uint   count;
    int    cells_count;
    float2 corner1;
    float2 corner2;
    float2 corner3;
    float2 corner4;

    float gray_0;
    float gray_1;
    
    float2 f0_pos;
    float2 f1_pos;
    float2 f2_pos;

    float2 f0_up_1;
    float2 f0_up_2;
    float2 f0_up_3;
    float2 f0_right_1;
    float2 f0_right_2;
    float2 f0_right_3;
    float2 f0_down_1;
    float2 f0_down_2;
    float2 f0_down_3;
    float2 f0_left_1;
    float2 f0_left_2;
    float2 f0_left_3;

    float2 f1_up_1;
    float2 f1_up_2;
    float2 f1_up_3;
    float2 f1_right_1;
    float2 f1_right_2;
    float2 f1_right_3;
    float2 f1_down_1;
    float2 f1_down_2;
    float2 f1_down_3;
    float2 f1_left_1;
    float2 f1_left_2;
    float2 f1_left_3;

    float2 f2_up_1;
    float2 f2_up_2;
    float2 f2_up_3;
    float2 f2_right_1;
    float2 f2_right_2;
    float2 f2_right_3;
    float2 f2_down_1;
    float2 f2_down_2;
    float2 f2_down_3;
    float2 f2_left_1;
    float2 f2_left_2;
    float2 f2_left_3;

    float2 top;
    float2 right;
    float2 down;
    float2 left;
    float2 center;
    
    uint   frame_id;
    int    bits_offset;
    uint   id;
};