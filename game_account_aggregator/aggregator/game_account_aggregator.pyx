from math import isinf

# This has specifically been optimized to run quickly for adding stats for many teams
# and players. Consider the affect on runtime when modifying
def _add_stat_into_dicts(entity, str_id, category, stat, value, all_labels, game_accounts_totals):
    for label in all_labels:
        try:
            stats_object = game_accounts_totals[label]
        except KeyError:
            game_accounts_totals[label] = {'team': {}, 'player': {}}
            stats_object = game_accounts_totals[label]

        try:
            stats_object = stats_object[entity]
        except KeyError:
            stats_object[entity] = {}
            stats_object = stats_object[entity]

        try:
            stats_object = stats_object[str_id]
        except KeyError:
            stats_object[str_id] = {}
            stats_object = stats_object[str_id]

        try:
            stats_object = stats_object[category]
        except KeyError:
            stats_object[category] = {}
            stats_object = stats_object[category]

        try:
            stats_object[stat] += value
        except KeyError:
            stats_object[stat] = value

# We implicitly pivot from a form that looks like:
# {team: [{category: [{'s':<stat> , 'v': <value>}], id: <id>}]} to:
# {team: {<id>: {category: {<stat>:<value>}}}}
def add_game_account_into_aggregate_dict(game_account, labels, categories, id_white_list, game_accounts_totals):
    stats = game_account['stats']
    for entity, entity_stats in stats.iteritems():
        for stat_object in entity_stats:
            str_id = str(stat_object['id'])
            if str_id in id_white_list:
                for category, category_stat_object in stat_object.iteritems():
                    if category in categories:
                        for stat_entry in category_stat_object:
                            if not isinf(stat_entry['v']):
                                _add_stat_into_dicts(entity, str_id, category, stat_entry['s'], stat_entry['v'], labels, game_accounts_totals)