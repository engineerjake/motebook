package com.motebook;

import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.event.player.UseEntityCallback;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.item.ItemStack;
import net.minecraft.item.Items;
import net.minecraft.nbt.NbtCompound;
import net.minecraft.nbt.NbtList;
import net.minecraft.nbt.NbtString;
import net.minecraft.text.Text;
import net.minecraft.util.ActionResult;
import net.minecraft.util.Hand;
import net.minecraft.world.World;

public class MoteBookMod implements ModInitializer {

    // Max characters per page in a book
    private static final int MAX_PAGE_CHARS = 256;

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
            addUsernameToBook(heldItem, username, player, world);

            return ActionResult.SUCCESS;
        });
    }

    private void addUsernameToBook(ItemStack bookStack, String username, PlayerEntity player, World world) {
        NbtCompound nbt = bookStack.getOrCreateNbt();

        // Get existing pages or create new list
        NbtList pages;
        if (nbt.contains("pages", 9)) { // 9 = NbtElement.LIST_TYPE
            pages = nbt.getList("pages", 8); // 8 = NbtElement.STRING_TYPE
        } else {
            pages = new NbtList();
        }

        String newLine = username + "\n";

        if (pages.isEmpty()) {
            // No pages yet — create the first page
            pages.add(NbtString.of(newLine));
        } else {
            // Get the last page content
            String lastPage = pages.getString(pages.size() - 1);

            if (lastPage.length() + newLine.length() <= MAX_PAGE_CHARS) {
                // Fits on the current page — append to it
                pages.set(pages.size() - 1, NbtString.of(lastPage + newLine));
            } else {
                // Doesn't fit — start a new page
                pages.add(NbtString.of(newLine));
            }
        }

        nbt.put("pages", pages);
        bookStack.setNbt(nbt);

        player.sendMessage(Text.literal("§aAdded §e" + username + "§a to your book."), true);
    }
}