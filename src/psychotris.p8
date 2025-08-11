pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
    trigger_next_level('intro')
end

function trigger_next_level(level)
    levels[level].init()
    current_level = level
end

function _draw()
    -- debug_draw_piece()
    levels[current_level].draw()

    if is_flipped then
        rotate_screen()
    end
end

function _update()
    levels[current_level].update()
end

row_removed_score = {1, 2, 3, 10}

function init_intro()
    intro_start = time()
    flip_start = 0
    cracks = {}
end

function generate_crack()
    return {start_x = rnd(128), start_y = rnd(128), dx = rnd(3) - 1 * 2, dy=rnd(3) - 1}
end

function update_intro()
    if time() - intro_start > 10 or btnp(2) then
        is_flipped = false
        trigger_next_level('main')
        return
    end

    add(cracks, generate_crack())


    if time() - intro_start > 0.5 and rnd(100) < 10 and flip_start == 0 then
        is_flipped = true
        flip_start = time()
    elseif time() - flip_start >= 1 then
        is_flipped = false
    end
end

function draw_crack(crack)
    line(crack.start_x, crack.start_y, crack.start_x + crack.dx, crack.start_y + crack.dy, 0)
end

function draw_intro()
    cls(5)
    print('\n\n\n\n--------------------------------\n' ..
'       do not be scared.\n\n' ..
'     you will see things that\n'..
'          are not there.' ..
'\n\n\n   but they will be real to you\n\n'..
'    your eyes are not your own\n'..
'--------------------------------'
,0 , 0, 7)
    pal(0, 0)
    local diff = (time() - intro_start) * 10
    circfill(0, 0, diff, 8)
    circfill(0, 128, diff, 8)
    circfill(128, 0, diff, 8)
    circfill(128, 128, diff, 8)
    for i = 1,#cracks do
        if cracks[i] ~= nil then
            draw_crack(cracks[i])
        end
    end

    if diff > 60 then
        print('they are mine', rnd(128), rnd(128), 0)
    end


    pal()
end

function rotate_screen_2()
    local mid = 4095
    local midPoint = mid + 0x6000
    for i=0x6000, midPoint, 4 do
        local exitPoint = (0x7ffb - i) + 0x6000
        local exit = peek4(exitPoint)
        poke4(exitPoint, peek4(i))
        poke4(i, exit)
    end
    --memcpy(midPoint, 0x6000, mid)
end

function rotate_screen()
    camera()
    pal()
    for i=0, 64, 1 do
        for j = 0, 128, 1 do
            local new_x = 128 - i
            local new_y = 128 - j

            local exit = pget(i, j)

            pset(i, j, pget(new_x, new_y))
            pset(new_x, new_y, exit)
        end
    end
    --memcpy(midPoint, 0x6000, mid)
end


function debug_draw_piece()
    cls()
    camera()
    piece = generate_backwards_l_piece()

    draw_grid()
    draw_piece(piece)
    rotate_piece(piece)
    camera(0, -24)

    draw_piece(piece)
    rotate_piece(piece)
    camera(0, -48)

    draw_piece(piece)
    rotate_piece(piece)
    camera(0, -72)

    draw_piece(piece)
    rotate_piece(piece)
    camera(0, -96)

    draw_piece(piece)
    rotate_piece(piece)


    piece = generate_square_piece()

    camera(48, 0)
    draw_piece(piece)
    rotate_piece(piece)
    camera(48, -24)

    draw_piece(piece)
    rotate_piece(piece)
    camera(48, -48)

    draw_piece(piece)
    rotate_piece(piece)
    camera(48, -72)

    draw_piece(piece)
    rotate_piece(piece)
    camera(48, -96)

    draw_piece(piece)
    rotate_piece(piece)
end

function generate_long_piece()
    return { blocks={
            {x=64, y = 0},
            {x=72, y = 0},
            {x=80, y = 0},
            {x=88, y = 0},
        },
        color=12,
        type='long',
        is_placed=false,
        rotation=1
    }
end

function generate_s_piece()
    return { blocks={
            {x=64, y = 8},
            {x=72, y = 8},
            {x=72, y = 0},
            {x=80, y = 0},
        },
        color=11,
        type='s',
        is_placed=false,
        rotation=1
    }
end

function generate_backwards_s_piece()
    return { blocks={
            {x=64, y = 0},
            {x=72, y = 0},
            {x=72, y = 8},
            {x=80, y = 8},
        },
        color=8,
        type='backwards-s',
        is_placed=false,
        rotation=1
    }
end

function generate_square_piece()
    return { blocks={
            {x=64, y = 0},
            {x=64, y = 8},
            {x=72, y = 0},
            {x=72, y = 8},
        },
        color=10,
        type='square',
        is_placed=false,
        rotation=1
    }
end

function generate_l_piece()
    return { blocks={
            {x=64, y = 8},
            {x=64, y = 0},
            {x=72, y = 8},
            {x=80, y = 8},
        },
        color=13,
        type='l',
        is_placed=false,
        rotation=1
    }
end

function generate_backwards_l_piece()
    return { blocks={
            {x=64, y = 8},
            {x=72, y = 8},
            {x=80, y = 8},
            {x=80, y = 0},
        },
        color=9,
        type='backwards-l',
        is_placed=false,
        rotation=1
    }
end

function generate_e_piece()
    return { blocks={
            {x=64, y = 8},
            {x=72, y = 8},
            {x=72, y = 0},
            {x=80, y = 8},
        },
        color=2,
        type='e',
        is_placed=false,
        rotation=1
    }
end

function generate_new_piece()
    local random_piece = flr(rnd(6))

    if random_piece == 0 then
        return generate_long_piece()
    elseif random_piece == 1 then
        return generate_square_piece()
    elseif random_piece == 2 then
        return generate_l_piece()
    elseif random_piece == 3 then
        return generate_backwards_l_piece()
    elseif random_piece == 4 then
        return generate_s_piece()
    elseif random_piece == 5 then
        return generate_backwards_s_piece()
    else
        return generate_e_piece()
    end
end

function reset_piece_position(piece)
    if piece.type == 'long' then
        piece.blocks = generate_long_piece().blocks
    elseif piece.type == 'square' then
        piece.blocks = generate_square_piece().blocks
    elseif piece.type == 'l' then
        piece.blocks = generate_l_piece().blocks
    elseif piece.type == 'backwards-l' then
        piece.blocks = generate_backwards_l_piece().blocks
    elseif piece.type == 'e' then
        piece.blocks = generate_e_piece().blocks
    elseif piece.type == 's' then
        piece.blocks = generate_s_piece().blocks
    elseif piece.type == 'backwards-s' then
        piece.blocks = generate_backwards_s_piece().blocks
    end

    piece.is_placed = false

    return piece
end

function init_main()
    upcoming_pieces = {}

    for i=1, 6 do
        add(upcoming_pieces, generate_new_piece())
    end

    pieces = {}
    current_piece = nil
    piece_start_time = time()
    total_rows_removed = 0
    hallucination_pieces = {}

    hold_piece = nil
    has_pressed_hold_this_piece = false

    matched_x_ago = 0

    is_game_over = false
end


function draw_grid()
    rectfill(16, 0, 96, 128, 5)
    for x=16, 96, 8 do
        for y=0, 128, 8 do
            rectfill(x + 1, y + 1, x + 6, y + 6, 0)
        end
    end
end

function draw_piece(piece)
    local can_move_in_y = can_move_in_direction(piece, 0, 1)

    if piece.is_placed then
        pal(0, 5)
    end
    for i=1, #piece.blocks do
        local block = piece.blocks[i]
        rectfill(block.x, block.y, block.x + 8, block.y + 8, 0)
        rectfill(block.x + 1, block.y + 1, block.x + 7, block.y + 7, piece.color)
    end
    pal()
end

function smallest_x(piece)
    local x = 9000
    for i=1, #piece.blocks do
        local block = piece.blocks[i]
        if block.x < x then
            x = block.x
        end
    end

    return x
end

function smallest_y(piece)
    local y = 9000
    for i=1, #piece.blocks do
        local block = piece.blocks[i]
        if block.y < y then
            y = block.y
        end
    end

    return y
end

function draw_tiny_piece(piece)
    local x = smallest_x(piece)
    local y = smallest_y(piece)

    for i=1, #piece.blocks do
        local block = piece.blocks[i]
        local scaled_x = (block.x - x) / 4
        local scaled_y = (block.y - y) / 4

        rectfill(scaled_x, scaled_y, scaled_x + 2, scaled_y + 2, 0)
        rectfill(scaled_x + 1, scaled_y + 1, scaled_x + 1, scaled_y + 1, piece.color)
    end
end

function draw_shrunk_piece(piece)
    local x = smallest_x(piece)
    local y = smallest_y(piece)

    for i=1, #piece.blocks do
        local block = piece.blocks[i]
        local scaled_x = (block.x - x) / 2
        local scaled_y = (block.y - y) / 2

        rectfill(scaled_x, scaled_y, scaled_x + 4, scaled_y + 4, 0)
        rectfill(scaled_x + 1, scaled_y + 1, scaled_x + 3, scaled_y + 3, piece.color)
    end
end

function draw_main()
    cls()

    if matched_x_ago > 0 then
        local x = #hallucination_pieces * 2

        if x < 3 then
            x = 3
        end

        camera(rnd(x) - x / 2, rnd(x) - x / 2)
    end

    draw_grid()
    camera()

    for i=1, #pieces do
        if is_game_over then
            camera(rnd(128) - 65, rnd(30) - 15)
        end
        draw_piece(pieces[i])
    end


    for i=1, #upcoming_pieces do
        camera(-100, (i - 1)*-18)
        draw_shrunk_piece(upcoming_pieces[i])
        camera()
    end
    camera()

    if current_piece ~= nil then
        draw_piece(current_piece)
    end
    print(total_rows_removed, 2, 64, 7)

    camera()
    for i=1, #hallucination_pieces do
        draw_piece(hallucination_pieces[i])
    end


    print('hold \n(X)', 0, 2, 7)
    if has_pressed_hold_this_piece then
        pal(5, 8)
    end

    rectfill(0, 16, 14, 24, 5)
    rectfill(1, 17, 13, 23, 0)
    camera(-3, -18)
    if hold_piece ~= nil then
        draw_tiny_piece(hold_piece)
    end
    camera()
    pal()


    if is_game_over then
        for i=1,rnd(200) + 1 do
            print('the pieces are coming for you', rnd(128), rnd(128), rnd(12))
        end
    end
end

function can_move_in_direction(piece, dx, dy)
    for i=1, #piece.blocks do
        local block = piece.blocks[i]

        if block.x == 16 and dx < 0 then
            return false
        elseif block.x == 88 and dx > 0 then
            return false
        end
        if abs(dy) > 0 and block.y == 120 then
            return false
        end

        for j=1, #pieces do
            local other_piece = pieces[j]

            for b=1, #other_piece.blocks do
                local other_block = other_piece.blocks[b]
                if block.x == other_block.x and block.y + 8 == other_block.y then
                    return false
                end

                if block.y == other_block.y and block.x + dx == other_block.x then
                    return false
                end
            end
        end
    end

    return true
end

function move_piece(piece, dx, dy)
    if piece == nil then
        return
    end
    local can_move_in_x = can_move_in_direction(piece, dx, 0)
    local can_move_in_y = can_move_in_direction(piece, 0, dy)

    for i=1, #piece.blocks do
        local block = piece.blocks[i]

        if can_move_in_x then
            block.x += dx
        end
        if can_move_in_y then
            block.y += dy
        end
    end
end

function rotate(origin, point, angle)
    qx = origin.x + cos(angle) * (point.x - origin.x) - sin(angle) * (point.y - origin.y)
    qy = origin.y + sin(angle) * (point.x - origin.x) + cos(angle) * (point.y - origin.y)
    return {x=qx, y=qy}
end


function origin_point(piece)
    local x = 9000
    local y = 9000

    for i=1, #piece.blocks do
        local block = piece.blocks[i]


        if block.x < x then
            x = block.x
        end

        if block.y < y then
            y = block.y
        end
    end

    if piece.type == 'square' then
        return {x = x + 4, y = y + 4}
    elseif piece.type == 'l' then
        if piece.rotation == 1 then
            return {x = x + 4, y = y + 4}
        elseif piece.rotation == 2 then
            return {x = x + 4, y = y + 12}
        elseif piece.rotation == 3 then
            return {x = x + 8, y = y + 8}
        else
            return {x = x, y = y + 8}
        end
    elseif piece.type == 'backwards-l' then
        if piece.rotation == 1 then
            return {x = x + 12, y = y + 4}
        elseif piece.rotation == 2 then
            return {x = x , y = y + 8}
        elseif piece.rotation == 3 then
            return {x = x + 8, y = y}
        else
            return {x = x + 8, y = y + 8}
        end
    elseif piece.type == 'e' then
        if piece.rotation == 1 then
            return {x = x + 8, y = y + 8}
        elseif piece.rotation == 2 then
            return {x = x , y = y + 8}
        elseif piece.rotation == 3 then
            return {x = x + 8, y = y}
        else
            return {x = x + 8, y = y + 8}
        end
    elseif piece.type == 's' then
        if piece.rotation == 1 then
            return {x = x + 8, y = y + 8}
        elseif piece.rotation == 2 then
            return {x = x , y = y + 8}
        elseif piece.rotation == 3 then
            return {x = x + 8, y = y + 8}
        else
            return {x = x, y = y + 8}
        end
    elseif piece.type == 'backwards-s' then
        if piece.rotation == 1 then
            return {x = x + 8, y = y + 8}
        elseif piece.rotation == 2 then
            return {x = x , y = y + 8}
        elseif piece.rotation == 3 then
            return {x = x + 8, y = y + 8}
        else
            return {x = x, y = y + 8}
        end
    elseif piece.type == 'long' then
        if piece.rotation == 1 then
            return {x = x + 12, y = y + 4}
        elseif piece.rotation == 2 then
            return {x = x, y = y + 8}
        elseif piece.rotation == 3 then
            return {x = x + 8, y = y}
        else
            return {x = x + 4, y = y + 12}
        end
    else
        return {x = x + 8, y = y + 8}
    end
end

function can_rotate(piece)
    local origin = origin_point(piece)
    for i=1, #piece.blocks do
        local block = piece.blocks[i]

        local rotated = rotate(origin, block, -0.25)

        if rotated.x < 0 or rotated.y < 0 or rotated.x > 88 then
            return false
        end

        for j=1, #pieces do
            local other_piece = pieces[j]

            for x=1, #other_piece.blocks do
                local other_block = other_piece.blocks[x]

                if rotated.x == other_block.x and rotated.y == other_block.y then
                    return false
                end
            end
        end
    end

    return true
end

function rotate_piece(piece)
    if not can_rotate(piece) then
        return
    end
    local origin = origin_point(piece)
    for i=1, #piece.blocks do
        local block = piece.blocks[i]

        local rotated = rotate(origin, block, -0.25)

        block.x = rotated.x
        block.y = rotated.y

    end
    piece.rotation += 1
    if piece.rotation > 4 then
        piece.rotation = 1
    end
end

function place_piece(piece)
    current_piece.is_placed = true
    add(pieces, current_piece)
    current_piece = nil
end

function get_new_current_piece()
    current_piece = upcoming_pieces[1]
    del(upcoming_pieces, upcoming_pieces[1])
    add(upcoming_pieces, generate_new_piece())
    piece_start_time = time()
    has_pressed_hold_this_piece = false
    reached_resting_place = false
end

function is_row_complete(y)
    local seen_pieces = {}
    local seen_blocks = {}
    for i=1, #pieces do
        local piece = pieces[i]
        for j=1, #piece.blocks do
            local block = piece.blocks[j]
            if block.y == y then
                add(seen_pieces, piece)
                add(seen_blocks, block)
            end
        end
    end

    return {pieces=seen_pieces, blocks=seen_blocks}
end

function has_lost()
    for i=1, #pieces do
        local piece = pieces[i]
        for j=1, #piece.blocks do
            local block = piece.blocks[j]
            if block.y <= 0 then
                return true
            end
        end
    end

    return false
end

function update_main()
    if is_game_over then
        return
    end

    if current_piece ~= nil then
        if btnp(2) then
            for _=0, 14 do
                 move_piece(current_piece, 0, 8)
            end
            place_piece(current_piece)
        elseif not has_pressed_hold_this_piece and btnp(5) then
            has_pressed_hold_this_piece = true
            local shifted_piece = reset_piece_position(current_piece)
            current_piece = hold_piece
            hold_piece = shifted_piece
        elseif btnp(4) then
            rotate_piece(current_piece, true)
        else
            local dx = 0
            local dy = 0
            if btnp(0) then
                dx += -8
            end
            if btnp(1) then
                dx += 8
            end
            if btnp(3) then
                dy += 8
            end

            if reached_resting_place and abs(dx) > 0 then
                piece_start_time = time()
            end

            local time_diff = time() - piece_start_time

            if time_diff + (total_rows_removed / 100) > 1 then
                if reached_resting_place then
                    place_piece(current_piece)
                else
                    piece_start_time = time()
                    dy += 8
                end
            end

            if current_piece ~= nil then
                move_piece(current_piece, dx, dy)
                if not can_move_in_direction(current_piece, 0, dy) then
                    reached_resting_place = true
                end
            end
        end
    end

    if current_piece == nil then
        get_new_current_piece()
    end

    local rows_removed = {}
    for y=0, 120, 8 do
        local row = is_row_complete(y)

        if #row.blocks == 10 then
            add(rows_removed, y)
            for i=1, #row.pieces do
                for j=1, #row.blocks do
                    del(row.pieces[i].blocks, row.blocks[j])
                end
            end
        end
    end

    for _=1, #rows_removed do
        local pieces_to_move = {}
        for i=1, #pieces do
            for j=1, #pieces[i].blocks do
                if pieces[i].blocks[j].y < rows_removed[1] then
                    add(pieces_to_move, pieces[i])
                    break
                end
            end
        end

        for i=1, #pieces_to_move do
            for j=1, #pieces_to_move[i].blocks do
                pieces_to_move[i].blocks[j].y += 8
            end
        end

        if #hallucination_pieces > 0 then
            del(hallucination_pieces, hallucination_pieces[1])
        end
    end

    if #rows_removed == 0 then
        if total_rows_removed > -1 and total_rows_removed - #hallucination_pieces > 0 and rnd(1000) < total_rows_removed then
            local new_hallucination = generate_new_piece()
            local dx_mod = flr(rnd(10)) - 7
            move_piece(new_hallucination, dx_mod * 8, 0)

            add(hallucination_pieces, new_hallucination)

            if rnd(100) < total_rows_removed and not is_flipped then
                is_flipped = true
            end
        end

        if matched_x_ago > 0 then
            matched_x_ago -= 1
        end
    else
        if is_flipped then
            is_flipped = false
        end
        total_rows_removed += row_removed_score[#rows_removed]
        matched_x_ago += 10 * #rows_removed

        for i=#pieces,1 do
            if #pieces[i].blocks == 0 then
                del(pieces, pieces[i])
            end
        end

        if total_rows_removed > 300 then
            if rnd(1000) < 10 then
                trigger_next_level('temp-face')
                return
            end
        end
    end

    for i=1, #hallucination_pieces do
        local hallucination = hallucination_pieces[i]

        local gone_over = false

        for j=1, #hallucination.blocks do
            hallucination.blocks[j].y += 8

            if hallucination.blocks[j].y >= 128 then
                gone_over = true
            end
        end

        if gone_over then
            for j=1, #hallucination.blocks do
                hallucination.blocks[j].y -= 142
            end
        end
    end

    is_game_over = has_lost()
end

function init_temp_face()
    eye_cracks = {}
    cracks = {}
    crack_distance = 0
    timing = 0
end

function draw_temp_face()
    if timing < 100 then
        cls()
    end
    pal()


    if timing >= 100 then
        camera(rnd(2) - 1, rnd(2) - 1)
    end
    sspr(0, 0, 64, 64, 0, 0, 128, 128)

    if timing >= 100 then
        pal(8, 9)
    end
    for i=1,#eye_cracks do
        if eye_cracks[i] ~= nil then
            if eye_cracks[i].eye == 0 then
                line(eye_cracks[i].x, eye_cracks[i].y, 40, 64, 8)
            else
                line(eye_cracks[i].x, eye_cracks[i].y, 80, 64, 8)
            end
        end
    end

    if timing >= 50 then
        for i = 1,#cracks do
            if cracks[i] ~= nil then
                draw_crack(cracks[i])
            end
        end
    end

    if timing >= 100 and rnd(100) < 20 then
        pal(6, 8)
    end
    circfill(40, 64, 10, 6)
    circfill(80, 64, 10, 6)

    camera()
    pal()

    if timing >= 100 then
        for _=0, rnd(timing) do
            print('reality has cracks', 6 + rnd(48), rnd(timing % 12) + rnd(118), 8)
        end

        for _ =0, rnd(6) do
            print('help me', 6 + rnd(84), rnd(timing % 12) + rnd(118), 0)
        end
    end
end

function generate_eye_crack()
    if rnd(100) <= 50 then
        return {x=30 + rnd(20) + crack_distance * 2, y= 64 + rnd(20) + crack_distance * 2, eye=0}
    else
        return {x=70 + rnd(20) - crack_distance * 2, y=64 + rnd(20) + crack_distance * 2, eye=1}
    end
end

function generate_body_crack()
    local new_crack = {start_x = rnd(128), start_y = rnd(128), dx = rnd(3) - 1 * 2, dy=rnd(3) - 1}
    return new_crack
end

function update_temp_face()

    timing += 1

    if timing % 10 == 0 then
        crack_distance += 1
    end

    if timing < 200 then
        if #eye_cracks > 200 then
            for _ = 0, rnd(20) do
                del(eye_cracks, eye_cracks[0])
                del(eye_cracks, eye_cracks[1])
            end

            for i=0, crack_distance do
                del(eye_cracks, eye_cracks[0])
            end
        end

        for i=0, rnd(20 + crack_distance) do
            add(eye_cracks, generate_eye_crack())
        end

        for i=0, rnd(20) do
            add(cracks, generate_body_crack())
        end
    else
        current_level = 'main'
    end


end


levels = {
    ['main']={
        init=init_main,
        draw=draw_main,
        update=update_main
    },
    ['intro']={
        init=init_intro,
        draw=draw_intro,
        update=update_intro
    },
    ['temp-face']={
        init=init_temp_face,
        draw=draw_temp_face,
        update=update_temp_face
    }
}

__gfx__
00000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444444444444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000
00044444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000
00044444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000
00044444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000000
04444444444444444444444444444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000
04444444444444444444444444444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000
044444444444444444444444444444fffffffffffffffffff4444444440000000000000000000000000000000000000000000000000000000000000000000000
00444444444ffffffffffffffffffffffffffffffffffffffff44444440000000000000000000000000000000000000000000000000000000000000000000000
0044444444ffffffffffffffffffffffffffffffffffffffffff4444440000000000000000000000000000000000000000000000000000000000000000000000
004444444fffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
004444444fffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
004444444fffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
00444444ffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
0000ffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
00000fffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000
00000ffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000
00000ffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000
00000fffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
00000fffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
00000fffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000ffffffffffff22222222222222222222222fffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
000000fffffffffff2222222222222222222222222ffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
0000000ffffffffff2222222222222222222222222ffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffff22222222222222222222222222ffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffff22222222222222222222222fffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000fffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000fffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000fffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000ffffffff00000000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000
