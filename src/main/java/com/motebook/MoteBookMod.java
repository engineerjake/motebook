package com.motebook;

import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.event.player.UseEntityCallback;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.text.Text;
import net.minecraft.util.ActionResult;
import net.minecraft.util.Hand;

public class MoteBookMod implements ModInitializer {

    private static final org.slf4j.Logger LOGGER = org.slf4j.LoggerFactory.getLogger("motebook");

    @Override
    public void onInitialize() {
        UseEntityCallback.EVENT.register((player, world, hand, entity, hitResult) -> {
            // Only run on the server side
            if (world.isClient()) return ActionResult.PASS;

            // Only trigger when right-clicking a player
            if (!(entity instanceof PlayerEntity targetPlayer)) return ActionResult.PASS;

            // Only trigger when holding a Book and Quill in the main hand
            ItemStack heldItem = player.getStackInHand(hand);
            if (hand != Hand.MAIN_HAND || !heldItem.isOf(Items.WRITABLE_BOOK)) return ActionResult.PASS;

            String username = targetPlayer.getName().getString();
            
            // Log the interaction
            player.sendMessage(
                Text.literal("§aRight-clicked player: §e" + username), 
                false
            );

            return ActionResult.SUCCESS;
        });
        
        LOGGER.info("Mote Book Mod initialized!");
    }
}