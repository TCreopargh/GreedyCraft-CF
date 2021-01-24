/*
 * This script is created for the GreedyCraft modpack by TCreopargh.
 * You may NOT use this script in any other publicly distributed modpack without my permission. 
 */ 

#priority 50

import crafttweaker.event.CommandEvent;
import crafttweaker.event.PlayerRespawnEvent;
import crafttweaker.player.IPlayer;
import crafttweaker.item.IItemStack;
import crafttweaker.event.EntityLivingDeathEvent;
import crafttweaker.data.IData;
import crafttweaker.block.IBlock;
import crafttweaker.world.IBlockPos;
import crafttweaker.block.IBlockState;
import crafttweaker.entity.IEntity;
import crafttweaker.entity.IEntityLivingBase;
import crafttweaker.entity.AttributeInstance;

import mods.ctutils.utils.Math;
import mods.ctutils.world.IGameRules;
import mods.zenutils.command.ZenCommand;
import mods.zenutils.command.ZenUtilsCommandSender;
import mods.zenutils.command.CommandUtils;
import mods.zenutils.command.IGetTabCompletion;
import mods.zenutils.command.TabCompletion;
import mods.zenutils.StringList;
import mods.zenutils.I18n;

import scripts.util.lang as LangUtil;

function compareItemStack(a as IItemStack, b as IItemStack) as bool {
    if(a.definition.id == b.definition.id && a.metadata == b.metadata) {
        return true;
    }
    return false;
}

val purgeCommand as ZenCommand = ZenCommand.create("purge");
purgeCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.purgeCommand.usage");
};
purgeCommand.requiredPermissionLevel = 0; 
purgeCommand.execute = function(command, server, sender, args) {
    server.commandManager.executeCommand(server, "/kill @e[type=Item]");
    var player as IPlayer = CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    if(!isNull(player)) {
        player.sendChat(game.localize("greedycraft.command.purgeCommand.chat"));
    }
};
purgeCommand.register();

val hideScoreboardCommand as ZenCommand = ZenCommand.create("hidescoreboard");
hideScoreboardCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.hideScoreboardCommand.usage");
};
hideScoreboardCommand.requiredPermissionLevel = 2; 
hideScoreboardCommand.execute = function(command, server, sender, args) {
    server.commandManager.executeCommand(server, "/scoreboard objectives remove title");
    var player as IPlayer = CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    if(!isNull(player)) {
        player.sendChat(game.localize("greedycraft.command.hideScoreboardCommand.chat"));
    }
};
hideScoreboardCommand.register();

val syncDifficultyCommand as ZenCommand = ZenCommand.create("syncdifficulty");
syncDifficultyCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.syncDifficultyCommand.usage");
};
syncDifficultyCommand.requiredPermissionLevel = 0; 
syncDifficultyCommand.tabCompletionGetters = [IGetTabCompletion.player()];
syncDifficultyCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            var maxDifficulty = 0;
            for stage in stageMap {
                var difficulty = stageMap[stage] as int;
                if(player.hasGameStage(stage) && difficulty > maxDifficulty) {
                    maxDifficulty = difficulty;
                }
            }
            player.difficulty = maxDifficulty;
            sender.sendMessage(I18n.format("greedycraft.command.syncDifficultyCommand.chat1", [player.name, "" + maxDifficulty] as string[]));
            player.sendChat(I18n.format("greedycraft.command.syncDifficultyCommand.chat2", "" + maxDifficulty));
        }
    }
};
syncDifficultyCommand.register();

val infinityStoneCommand as ZenCommand = ZenCommand.create("infinitykill");
infinityStoneCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.infinityStoneCommand.usage");
};
infinityStoneCommand.requiredPermissionLevel = 2; 
infinityStoneCommand.tabCompletionGetters = [IGetTabCompletion.player()];
infinityStoneCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            if(player.name == "TCreopargh") {
                player.addPotionEffect(<potion:minecraft:resistance>.makePotionEffect(50, 4, false, false));
                player.addPotionEffect(<potion:minecraft:strength>.makePotionEffect(50, 10, false, false));
                return;
            }
            if(!player.hasGameStage("iswuss")) {
                if(player.hasGameStage("truehero") || player.creative) {
                    player.addPotionEffect(<potion:minecraft:resistance>.makePotionEffect(50, 4, false, false));
                    player.addPotionEffect(<potion:minecraft:strength>.makePotionEffect(50, 10, false, false));
                    player.addPotionEffect(<potion:minecraft:regeneration>.makePotionEffect(50, 4, false, false));
                    return;
                }
            }
            server.commandManager.executeCommand(server, "/replaceitem entity " + player.name + " slot.armor.head additions:greedycraft-infinity_stone");
            server.commandManager.executeCommand(server, "/replaceitem entity " + player.name + " slot.armor.chest additions:greedycraft-infinity_stone");
            server.commandManager.executeCommand(server, "/replaceitem entity " + player.name + " slot.armor.legs additions:greedycraft-infinity_stone");
            server.commandManager.executeCommand(server, "/replaceitem entity " + player.name + " slot.armor.feet additions:greedycraft-infinity_stone");
            server.commandManager.executeCommand(server, "/give " + player.name + " additions:greedycraft-infinity_stone 1 0");
            server.commandManager.executeCommand(server, "/kill " + player.name);
            player.sendChat(game.localize("greedycraft.command.infinityStoneCommand.not_worth"));
        }
    }
};
infinityStoneCommand.register();

val unlockAllCommand as ZenCommand = ZenCommand.create("unlockallstages");
unlockAllCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.unlockAllCommand.usage");
};
unlockAllCommand.requiredPermissionLevel = 2; 
unlockAllCommand.tabCompletionGetters = [IGetTabCompletion.player()];
unlockAllCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            for stage in listStages {
                player.addGameStage(stage);
            }
            sender.sendMessage(I18n.format("greedycraft.command.unlockAllCommand.chat1", [player.name, "" + listStages.length] as string[]));
            player.sendChat(I18n.format("greedycraft.command.unlockAllCommand.chat2", "" + listStages.length));
        }
    }
};
unlockAllCommand.register();

val lockAllCommand as ZenCommand = ZenCommand.create("lockallstages");
lockAllCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.lockAllCommand.usage");
};
lockAllCommand.requiredPermissionLevel = 2; 
lockAllCommand.tabCompletionGetters = [IGetTabCompletion.player()];
lockAllCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            for stage in listStages {
                player.removeGameStage(stage);
            }
            sender.sendMessage(I18n.format("greedycraft.command.lockAllCommand.chat1", [player.name, "" + listStages.length] as string[]));
            player.sendChat(I18n.format("greedycraft.command.lockAllCommand.chat2", "" + listStages.length));
        }
    }
};
lockAllCommand.register();

val pureDaisyCommand as ZenCommand = ZenCommand.create("purifyingdust");
pureDaisyCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.pureDaisyCommand.usage");
};
pureDaisyCommand.requiredPermissionLevel = 2; 
pureDaisyCommand.tabCompletionGetters = [IGetTabCompletion.player()];
pureDaisyCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            if(player.world.remote) {
                return;
            }
            var x = player.x as int;
            var y = player.y as int;
            var z = player.z as int;
            var world = player.world;
            for i in (x - 7) to (x + 8) {
                for j in (y - 7) to (y + 8) {
                    for k in (z - 7) to (z + 8) {
                        if((i - x) * (i - x) + (j - y) * (j - y) + (k - z) * (k - z) >= 7 * 7) {
                            continue;
                        }
                        var blockOnPos as IBlock = world.getBlock(i, j, k);
                        if(blockOnPos.definition.id == "minecraft:air") {
                            continue;
                        }
                        var pos = crafttweaker.util.Position3f.create(i, j, k).asBlockPos();
                        for input in pureDaisyTransmutations {
                            if(isNull(input)) {
                                continue;
                            }
                            var output as IItemStack = pureDaisyTransmutations[input];
                            var transmutable = false;
                            var checkMeta = false;
                        
                            if(input.itemArray.length == 1 && input.itemArray[0].metadata != 0) {
                                checkMeta = true;
                            }
                            
                            for block in input.itemArray {
                                if(!isNull(block) && (block.definition.id == blockOnPos.definition.id) && (!checkMeta || block.metadata == blockOnPos.meta)) {
                                   transmutable = true;
                                   break;
                                }
                                if(block.isItemBlock && (block.asBlock().definition.id == blockOnPos.definition.id) && (!checkMeta || block.metadata == blockOnPos.meta)) {
                                   transmutable = true;
                                   break;
                                }
                            }
                            if(transmutable) {
                                var outputStack as IItemStack = pureDaisyTransmutations[input];
                                var states as string[] = [];
                                if(compareItemStack(outputStack, <minecraft:stonebrick:1>)) {
                                    states += "variant=mossy_stonebrick";
                                } else if(compareItemStack(outputStack, <minecraft:stonebrick:2>)) {
                                    states += "variant=cracked_stonebrick";
                                } else if(compareItemStack(outputStack, <botania:livingwood:1>)) {
                                    states += "variant=planks";
                                }
                                var blockState as IBlockState = IBlockState.getBlockState(outputStack.definition.id, states);
                                world.setBlockState(blockState, pos as IBlockPos);
                            }
                        }
                    }
                }
            }
            server.commandManager.executeCommand(server, "/particle explode " + player.x + " " + player.y + " " + player.z + " 8 8 8 0.2 1500 force " + player.name);
        }
    }
};
pureDaisyCommand.register();

val showDeathQuotesCommand as ZenCommand = ZenCommand.create("showdeathquotes");
showDeathQuotesCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.showDeathQuotesCommand.usage");
};
showDeathQuotesCommand.requiredPermissionLevel = 0; 
showDeathQuotesCommand.tabCompletionGetters = [IGetTabCompletion.player()];
showDeathQuotesCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            player.removeGameStage("hide_death_quotes");
            player.sendChat(game.localize("greedycraft.command.showDeathQuotesCommand.chat"));
        }
    }
};
showDeathQuotesCommand.register();

val hideDeathQuotesCommand as ZenCommand = ZenCommand.create("hidedeathquotes");
hideDeathQuotesCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.hideDeathQuotesCommand.usage");
};
hideDeathQuotesCommand.requiredPermissionLevel = 0; 
hideDeathQuotesCommand.tabCompletionGetters = [IGetTabCompletion.player()];
hideDeathQuotesCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            player.addGameStage("hide_death_quotes");
            player.sendChat(game.localize("greedycraft.command.hideDeathQuotesCommand.chat"));
        }
    }
};
hideDeathQuotesCommand.register();

val setMaidHealthCommand as ZenCommand = ZenCommand.create("setmaidhealth");
setMaidHealthCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.setMaidHealthCommand.usage");
};
setMaidHealthCommand.requiredPermissionLevel = 2; 
setMaidHealthCommand.tabCompletionGetters = [IGetTabCompletion.player(), IGetTabCompletion.player()];
setMaidHealthCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    var entities as IEntity[];
    if (args.length == 1) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer as IPlayer;
    } else if (args.length == 2) {
        players = CommandUtils.getPlayers(server, sender, args[1]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    if(players.length > 0) {
        var player = players[0];
        entities = CommandUtils.getEntityList(server, sender, args[0]) as IEntity[];
        for entity in entities {
            if(!isNull(player) && !isNull(entity) && entity instanceof IEntityLivingBase) {
                var entityBase as IEntityLivingBase = entity;
                var playerHealth as float = player.maxHealth as float;
                var maidHealth as float = playerHealth * 4.0 as float;
                //maidHealth = max(maidHealth as float, entityBase.maxHealth as float) as float;
                entityBase.addPotionEffect(<potion:potioncore:love>.makePotionEffect(1, 0, true, true));
                var potionLevel as int = Math.floor(maidHealth as float / 4.0 as float) as int;

                entityBase.addPotionEffect(<potion:minecraft:health_boost>.makePotionEffect(2147483647, potionLevel, false, false));
                entityBase.addPotionEffect(<potion:minecraft:instant_health>.makePotionEffect(1, potionLevel * 4, false, false));
                entityBase.addPotionEffect(<potion:minecraft:regeneration>.makePotionEffect(2147483647, 1, false, false));
                entityBase.addPotionEffect(<potion:minecraft:resistance>.makePotionEffect(2147483647, 1, false, false));
                
                /* This sonehow just doesn't work
                var data = {"Health": maidHealth as float, "Attributes":[{"Name":"generic.maxHealth", "Base": maidHealth as float}]} as IData;
                entityBase.update(data);
                var attribute as AttributeInstance = entityBase.getAttribute("generic.maxHealth") as AttributeInstance;
                attribute.removeAllModifiers();
                attribute.setBaseValue(maidHealth as double);
                entityBase.health = maidHealth as float;
                */
            }
        }
        player.sendChat(I18n.format("greedycraft.command.setMaidHealthCommand.chat", "" + entities.length));
    }
};
setMaidHealthCommand.register();

val giveOmnipediaCommand as ZenCommand = ZenCommand.create("giveomnipedia");
giveOmnipediaCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.giveOmnipediaCommand.usage");
};
giveOmnipediaCommand.requiredPermissionLevel = 2; 
giveOmnipediaCommand.tabCompletionGetters = [IGetTabCompletion.player()];
giveOmnipediaCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            player.give(omnipedia);
        }
    }
};
giveOmnipediaCommand.register();

val suicideCommand as ZenCommand = ZenCommand.create("suicide");
suicideCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.suicideCommand.usage");
};
suicideCommand.requiredPermissionLevel = 0;
suicideCommand.execute = function(command, server, sender, args) {
    var player as IPlayer = CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    if(!isNull(player)) {
        player.clearActivePotions();
        server.commandManager.executeCommand(server, "/kill " + player.name);
    }
};
suicideCommand.register();

val sendWelcomeQuoteCommand as ZenCommand = ZenCommand.create("sendwelcomequote");
sendWelcomeQuoteCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.sendWelcomeQuoteCommand.usage");
};
sendWelcomeQuoteCommand.requiredPermissionLevel = 2;
sendWelcomeQuoteCommand.tabCompletionGetters = [IGetTabCompletion.player()];
sendWelcomeQuoteCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            var quotes as string[] = welcomeQuotes[LangUtil.getLanguage()];
            var index as int = Math.floor(Math.random() * quotes.length) as int;
            if(index < 0) {
               index = 0;
            }
            if(index >= quotes.length) {
               index = quotes.length - 1;
            }
            var msg as string = quotes[index].replace("%playername%", player.name);
            if(!msg.startsWith("[")) {
                msg = '["",{"text":"' + game.localize("greedycraft.command.sendWelcomeQuoteCommand.tip") + ' ' + msg + '"}]';
            }
            server.commandManager.executeCommand(server, "/tellraw " + player.name + " " + msg);
        }
    }
};
sendWelcomeQuoteCommand.register();

val broadcastCommand as ZenCommand = ZenCommand.create("broadcast");
broadcastCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.broadcastCommand.usage");
};
broadcastCommand.requiredPermissionLevel = 2;
broadcastCommand.execute = function(command, server, sender, args) {
    var players as IPlayer[] = CommandUtils.getPlayers(server, sender, "@a") as IPlayer[];
    var str as string = "";
    for arg in args {
        str += arg;
        str += " ";
    }
    str = str.trim();
    for player in players {
        if(!isNull(player)) {
            player.sendChat(str);
        }
    }
};
broadcastCommand.register();

val executorCommand as ZenCommand = ZenCommand.create("executor");
executorCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.executorCommand.usage");
};
executorCommand.requiredPermissionLevel = 2;
executorCommand.tabCompletionGetters = [IGetTabCompletion.player()];
executorCommand.execute = function(command, server, sender, args) {
    if(args.length < 1) {
        CommandUtils.notifyWrongUsage(command, sender);
    }
    var players as IPlayer[] = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    for player in players {
        var permission as bool = true;
        if(player.hasGameStage("iswuss")) {
            permission = false;
        }
        if(player.name == "TCreopargh") {
            permission = true;
        }
        if(!permission) {
            player.sendChat(game.localize("greedycraft.command.executorCommand.deny"));
            continue;
        }
        player.sendChat(game.localize("greedycraft.command.executorCommand.message"));
    }
};
executorCommand.register();

val sendFirstJoinMessageCommand as ZenCommand = ZenCommand.create("sendfirstjoinmessage");
sendFirstJoinMessageCommand.getCommandUsage = function(sender) {
    return game.localize("greedycraft.command.sendFirstJoinMessageCommand.usage");
};
sendFirstJoinMessageCommand.requiredPermissionLevel = 2;
sendFirstJoinMessageCommand.tabCompletionGetters = [IGetTabCompletion.player()];
sendFirstJoinMessageCommand.execute = function(command, server, sender, args) {
        var players as IPlayer[] = [] as IPlayer[];
    if (args.length == 0) {
        players += CommandUtils.getCommandSenderAsPlayer(sender) as IPlayer;
    } else if (args.length == 1) {
        players = CommandUtils.getPlayers(server, sender, args[0]) as IPlayer[];
    } else {
        CommandUtils.notifyWrongUsage(command, sender);
        return;
    }
    for player in players {
        if(!isNull(player)) {
            player.sendChat(greetingMessage[LangUtil.getLanguage()].replace("%PLAYERNAME%", player.name));
        }
    }
};
sendFirstJoinMessageCommand.register();