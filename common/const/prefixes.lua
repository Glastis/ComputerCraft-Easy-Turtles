local prefixes = {}

prefixes.minecraft = 'minecraft:'
prefixes.mod = {}
prefixes.mod.minecraft = 'minecraft:'
prefixes.mod.enderstorage = 'enderstorage:'
prefixes.mod.thermal = 'thermal:'
prefixes.mod.create = 'create:'
prefixes.mod.alchemistry = 'alchemistry:'
prefixes.mod.chemlib = 'chemlib:'
prefixes.mod.toms_storage = 'toms_storage:'
prefixes.mod.advanced_generators = 'advgenerators:'
prefixes.mod.farmersdelight = 'farmersdelight:'
prefixes.mod.minecolonies = 'minecolonies:'
prefixes.mod.domum_ornamentoum = 'domum_ornamentoum:'

prefixes.blast_furnace = prefixes.mod.minecraft .. 'blast_furnace_'
prefixes.redstone = 'redstoneIntegrator_'
prefixes.barrel = prefixes.mod.minecraft .. 'barrel_'
prefixes.dropper = prefixes.mod.minecraft .. 'dropper_'
prefixes.turtle = 'turtle_'
prefixes.generator = prefixes.mod.thermal .. 'dynamo_stirling_'
prefixes.extruder = prefixes.mod.thermal .. 'device_rock_gen_'
prefixes.pulverizer = prefixes.mod.thermal .. 'machine_pulverizer_'
prefixes.electric_furnace = prefixes.mod.thermal .. 'machine_furnace_'
prefixes.dissolver = prefixes.mod.alchemistry .. 'dissolver_block_entity_'
prefixes.compactor = prefixes.mod.alchemistry .. 'compactor_block_entity_'
prefixes.portable_storage_interface = prefixes.mod.create .. 'portable_storage_interface_'
prefixes.inventory_connector = prefixes.mod.toms_storage .. 'ts.inventory_connector.tile_'
prefixes.ender_chest = prefixes.mod.enderstorage .. 'ender_chest_'
prefixes.advanced_generator_item_input = prefixes.mod.advanced_generators .. 'item_input_'
prefixes.colony_integrator = prefixes.mod.minecolonies .. 'colonyIntegrator_'

return prefixes