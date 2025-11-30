function hex_string_to_int(str)
    return tonumber(str, 16)
end

function int_to_hex_string(int)
    return string.format("%.8x", int)
end

-- Reverse 4-byte UID: AABBCCDD -> DDCCBBAA
function reverse_hex_string(str)
    return str:sub(7,8) .. str:sub(5,6) .. str:sub(3,4) .. str:sub(1,2)
end

function get_id_from_man_block(block)
    return string.sub(block, 1, 8)
end

function get_man_block(tagid, man_block)
    return tagid .. string.sub(man_block, 9, #man_block)
end

function tagid_change_test(man_block)
    print("=================== TAG-ID CHANGE TEST ===================")

    local cur_tagid = get_id_from_man_block(man_block)
    local new_tagid = int_to_hex_string(hex_string_to_int(cur_tagid) + 1)

    print("TAG 0: " .. cur_tagid)
    print("TAG 1: " .. new_tagid)

    print("OLD BLOCK: " .. get_man_block(cur_tagid, man_block))
    print("NEW BLOCK: " .. get_man_block(new_tagid, man_block))

    print("==========================================================\n")
end

function main(args)
    -- Initalizing variables
    local cur_man_block_1 = "a3b4912f221104008c5577125e900101"
    local cur_man_block_2 = "7f01c2ab3310020077aa44dd88990102"
    local cur_tag_id      = get_id_from_man_block(cur_man_block_2)

    -- Starting UID as integer (matches placeholder UID A3B4912F)
    local tag_id   = 2746519855

    -- Number of attempts
    local counter  = 30

    -- Step used for increasing / decreasing the UID
    local step     = 1

    -- Strategy selector:
    --   1 = random around base tag_id
    --   2 = increase tag_id
    --   3 = decrease tag_id
    local choice   = 2

    -- Seed RNG for random strategy
    math.randomseed(os.time())

    tagid_change_test(cur_man_block_2)

    while (counter ~= 0) do
        -- core.console("hf mf esetblk --blk 0 --data " .. cur_man_block_1)
        -- hf mf sim --4k -u f6b996ca

        if (choice == 1) then
            -- Emulate mifaire with random tag id around base tag_id

            local rand_offset   = math.random(-200, 200)
            local candidate_int = tag_id + rand_offset
            if candidate_int < 0 then
                candidate_int = 0
            end

            local new_tag_hex = int_to_hex_string(candidate_int)
            local new_uid     = reverse_hex_string(new_tag_hex)

            print("Random TAG (int): " .. candidate_int .. " | UID: " .. new_uid)
            core.console('hf mf sim --4k -u ' .. new_uid)

        elseif (choice == 2) then
            -- Emulate mifaire with increased tag id

            local new_tag_hex = int_to_hex_string(tag_id)
            local new_uid     = reverse_hex_string(new_tag_hex)

            print("Increased TAG (int): " .. tag_id .. " | UID: " .. new_uid)
            core.console('hf mf sim --4k -u ' .. new_uid)

            tag_id = tag_id + step

        elseif (choice == 3) then
            -- Emulate mifaire with decreased tag id

            if tag_id < 0 then
                tag_id = 0
            end

            local new_tag_hex = int_to_hex_string(tag_id)
            local new_uid     = reverse_hex_string(new_tag_hex)

            print("Decreased TAG (int): " .. tag_id .. " | UID: " .. new_uid)
            core.console('hf mf sim --4k -u ' .. new_uid)

            tag_id = tag_id - step
        end

        os.execute('sleep 2')
        counter = counter - 1
    end
end

main(args)
