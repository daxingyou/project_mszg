-record(role_tplt,{id,name,armor,weapon,skill1,skill2,describe,icon,heroicon,default_sculpture,fly_effect_id,front_effect_id,back_effect_id,init_sculpture,first_divine}).
-record(copy_group_tplt,{id,type,name,next_group_id,icon,first_copy_id,last_copy_id}).
-record(copy_tplt,{id,type,name,copy_group_id,need_power,gold,exp,award,describe,first_map_id,pre_copy,need_stone,dropitems,small_icon,recommended_battle_power,new_monsters}).
-record(game_map_tplt,{id,name,copy_id,room,monster,trap,buff,friend_role,barries_amount,map_rule_id,next_map,key_monster}).
-record(friend_role,{id,skill,icon}).
-record(game_map_rule_tplt,{id,monster,monster_pos,door,barries_pos}).
-record(monster_tplt,{id,name,icon,level,content,type,attack_type,relative_id,life,atk,speed,hit_ratio,critical_ratio,miss_ratio,tenacity,skills,special_skill,drop_rate,item_id,fly_effect_id,front_effect_id,back_effect_id}).
-record(item_tplt,{id,type,name,overlay_count,sell_price,sub_id,icon,describe,bind_type,quality}).
-record(equipment_tplt,{id,type,gem_trough,life,atk,speed,hit_ratio,miss_ratio,critical_ratio,tenacity,mf_rule,attr_ids,strengthen_id,equip_level,equip_use_level,combat_effectiveness,advance_id,recast_id}).
-record(equipment_mf_rule_tplt,{id,addtional_attr_max,addtional_attr_min,addtional_attr_ids,special_attr_max,special_attr_min,special_attr_ids,gem_trough}).
-record(equipment_attr_tplt,{id,attr_type,attr_values,prefix,value,combat_effectiveness}).
-record(equip_strengthen_tplt,{id,need_gold,attr_types,attr_values,strengthen_rate}).
-record(equipment_recast_tplt,{id,need_material,need_gold,mf_rule_id}).
-record(equipment_advance_tplt,{id,need_material,need_gold,advance_id}).
-record(equipment_resolve_tplt,{id,material_resolved}).
-record(trap_tplt,{id,skill,icon}).
-record(award_tplt,{id,name,award_type,award_id}).
-record(role_upgrad_tplt,{id,name,life,atk,speed,hit_ratio,critical_ratio,miss_ratio,tenacity,combat_effectiveness}).
-record(role_exp_tplt,{id,exp,unlock_ids}).
-record(game_award,{id,id_list1,amount_list1,list1_ratio,id_list2,amount_list2,list2_ratio,id_list3,amount_list3,list3_ratio,need_emoney}).
-record(power_hp_price,{the_time,price}).
-record(extend_pack_price,{the_time,price}).
-record(push_tower_copy,{id,min_level,max_level,first_map_id,base_gold,base_exp,gem_list,base_gem_count}).
-record(push_tower_map,{id,repeat_times,next_map,monsters,monster_min,monster_max,scene,traps,trap_min,trap_max,friends,friend_min,friend_max,awards,award_min,award_max,barrier_amount,award,gold,key_monster}).
-record(push_tower_award,{id,gem_lev1,lev1_radio,gem_lev2,lev2_radio,gem_lev3,lev3_radio,gem_lev4,lev4_radio}).
-record(task_tplt,{id,title,main_type,need_level,next_ids,sub_type,monster_id,clear_type,collect_id,location,number,text,reward_ids,reward_amounts}).
-record(sculpture_tplt,{id,type,name,role_type,skill_group,skill_id,max_lev,skill_cd,grade,icon,desc_ids}).
-record(sculpture_divine_tplt,{money_type,money_amounts,upgrade_rates,divine_award_file}).
-record(divine1_award_tplt,{id,level1,level2,level3,level4,level5}).
-record(divine2_award_tplt,{id,level1,level2,level3,level4,level5}).
-record(sculpture_convert_tplt,{id,frag_count,can_show}).
-record(gem_attributes,{id,name,type,life,atk,speed,hit_ratio,miss_ratio,critical_ratio,tenacity,unmounted_price,combat_effectiveness,small_icon}).
-record(gem_compound,{id,gold,related_id,success_rate,miss_rate}).
-record(equipment_lev_price,{level,percent,combat_effectiveness}).
-record(challenge_award_tplt,{id,ranking_range,success_points,success_honours,failed_points,failed_honours}).
-record(ranking_award_tplt,{id,ranking_range,points,honours}).
-record(ranking_copy_tplt,{id,lev_range,scene,friends,friend_min,friend_max,traps,trap_min,trap_max,barrier_amount,awards,award_min,award_max,monsters,monster_min,monster_max}).
-record(mall_item,{id,mall_item_type,item_id,item_amount,price_type,price,vip_discount,mark,buy_limit,tag_id,profession,level,show}).
-record(event_tplt,{id,name,type,skill,number,icon}).
-record(expression_tplt,{id,expression}).
-record(military_rank_tplt,{id,name,icon,need_honour,need_rank,reward_ids,reward_amounts}).
-record(point_mall_tplt,{id,mall_item_type,item_id,item_amount,price,tag_id,need_rank,profession,level,show}).
-record(gift_bag_tplt,{id,name,icon,item_id,item_amount,desc}).
-record(daily_award_tplt,{level_range,days1_award,days3_award,days7_award,days15_award}).
-record(activeness_task_tplt,{id,name,max_times,award_pertime}).
-record(activeness_reward_tplt,{id,ids,amounts,need_activess}).
-record(reward_item_tplt,{id,type,temp_id}).
-record(train_match_award_group,{id,min_lev,max_lev,blue_award,purple_award,orange_award,red_award}).
-record(train_match_award,{id,awards,amounts,radios}).
-record(nickname_tplt,{id,radio,content,secname}).
-record(benison_tplt,{id,name,icon,status_ids,duration,need_emoney}).
-record(benison_status_tplt,{id,attr_type,value_type,value}).
-record(randon_gift_bag_tplt,{id,gift_bag_ids,radios}).
-record(tutorial_item_tplt,{group_id,gift_bag_id}).
-record(stress_test_tplt,{id,name,next_action}).